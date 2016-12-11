class V1::ValidateController < ApplicationController
  require_relative '../../views/xml/xml_documents'

  def index
    xml_document = XmlDocuments.new('5000', '959595', 02, 12345678)
    render json: xml_document.is_valid.to_s
  end

  def validate_operation
    data = validate_operation_params
    company_decode = self.getCompany data[:company]
    #local validation
    order_model = V1::Order.new
    order_model.build(company_decode, data)
    if order_model.valid?
      order_model.save
      #API validation
      xml_document = XmlDocuments.new(order_model.amount, order_model.identifier, company_decode, order_model.order)
      xml_return = sendXmlPincenterApi(xml_document.validate.to_s)
      if xml_return == 'ERROR'
        return render json: "TIMEOUT", status: :bad_request
      end
      #view XML
      xml_return.xpath("//field[@id='b39']").each do |value|
        if value.content.to_s === '00'
          # save order on local database and set auth code
          xml_return.xpath("//subcampo[@id='69b63']").each do |auth_code|
            order_model.auth_code = auth_code.content.to_s
          end
          order_model.save
          # set form pay data for PayPlus
          key = self.get_pp_key
          concatenate = "PP_AMOUNT=#{order_model.amount}&PP_ORDER=#{order_model.order}"
          digest = OpenSSL::Digest.new('sha256')
          hash = OpenSSL::HMAC.hexdigest(digest, key, concatenate)
          response = {
              pp_shop: self.get_pp_shop,
              pp_amount: order_model.amount,
              pp_order: order_model.order,
              pp_product: "Recarga #{data[:company]}",
              pp_service: "Recarga #{order_model.identifier}",
              pp_name: "Recargame.cl DEV ENV",
              pp_hash: hash
          }
          #send data to client
          return render json: response, status: :ok
        else
          return render json: "#{company_decode.to_s} #{value.content.to_s}", status: :bad_request
        end
      end
      render json: 'Error validando los datos de la compañía', status: :bad_request
    else
      render json: order_model.errors.messages, status: :bad_request
    end
  end

  def validate_pay
    data = validate_pay_params
    order_model = V1::Order.find_by(order: data[:order])
    if order_model.status == 4
      render json: order_model.status, status: 200
    elsif order_model.status == 6
      render json: 6, status: 400
    elsif order_model.status == 8
      render json: 8, status: 400
    else
      render json: order_model.status, status: 200
    end
  end

  private
  def validate_operation_params
    params.require(:form).permit(:identifier, :amount, :email, :company)
  end

  def validate_pay_params
    params.permit(:order)
  end
end
