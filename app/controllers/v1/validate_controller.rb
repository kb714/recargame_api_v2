class V1::ValidateController < ApplicationController

  def index
    #V1::Order.delete_all
    data = V1::Order.order(:created_at => 'desc').all
    if data.exists?
      render json: JSON.pretty_generate(JSON.parse(data.to_json))
    else
      render json: "no content"
    end
  end

  def validate_operation
    data = validate_operation_params
    company_decode = self.getCompany data[:company]
    #check if, use after validate pay
    #local validation
    order_model = V1::Order.new
    order_model.build(company_decode, data)
    if order_model.valid?
      order_model.save
      #API validation
      xml_return = sendXmlPincenterApi ifIsValid(data[:amount], data[:identifier], company_decode, order_model.order)
      if xml_return == 'ERROR'
        return render json: "TIMEOUT", status: 400
      end
      xml_return.xpath("//field[@id='b39']").each do |value|
        if value.content.to_s === '00'
          # save order on local database and set auth code
          xml_return.xpath("//subcampo[@id='69b63']").each do |auth_code|
            order_model.auth_code = auth_code.content.to_s
          end
          order_model.save
          # set form pay data for PayPlus
          key = self.get_pp_key
          data = "PP_AMOUNT=#{data[:amount]}&PP_ORDER=#{order_model.order}"
          digest = OpenSSL::Digest.new('sha256')

          pp_shop = 399
          pp_amount = data[:amount]
          pp_order = order_model.order
          pp_product = 'Recarga'
          pp_service = "Recarga #{data[:identifier]}"
          pp_name = 'RECARGAME.CL'
          pp_hash = OpenSSL::HMAC.hexdigest(digest, key, data)
          response = {pp_shop: pp_shop, pp_amount: pp_amount, pp_order: pp_order, pp_product: pp_product,
                      pp_service: pp_service, pp_name: pp_name, pp_hash: pp_hash}
          #send data to client
          return render json: response, status: 200
        else
          return render json: "#{company_decode.to_s} #{value.content.to_s}", status: 400
        end
      end
      render json: 'Error validando los datos de la compañía', status: 400
    else
      render json: order_model.errors.messages, status: 400
    end
  end

  def validate_pay
    data = validate_pay_params
    order_model = V1::Order.find_by(order: data[:order])
    if order_model.status == 4
      render json: order_model.status, status: 200
    elsif order_model.status == 6
      render json: 6, status: 400
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

  #pincenter XML, unnused order parameter
  def ifIsValid(amount, identifier, company, order)
    t = Time.now
    t = t - 10800
    return Nokogiri::Slop <<-EOXML
      <isomsg>
        <field id="b0">0300</field>
        <field id="b3">510000</field>
        <field id="b4">#{amount.to_s}</field>
        <field id="b11">#{order.to_s}</field>
        <field id="b12">#{t.strftime('%H%M%S').to_s}</field>
        <field id="b13">#{t.strftime('%Y%m%d').to_s}</field>
        <field id="b24">9999</field>
        <field id="b25">02</field>
        <field id="b41">00000004</field>
        <field id="b63">
          <subcampo id="00b63">RECARGA0API0V1</subcampo>
          <subcampo id="03b63">0013</subcampo>
          <subcampo id="04b63">V002</subcampo>
          <subcampo id="05b63">01</subcampo>
          <subcampo id="06b63">99</subcampo>
          <subcampo id="11b63">0064</subcampo>
          <subcampo id="12b63">361988</subcampo>
          <subcampo id="14b63">361988</subcampo>
          <subcampo id="15b63">000381</subcampo>
          <subcampo id="20b63">14725836</subcampo>
          <subcampo id="61b63">#{company.to_s}</subcampo>
          <subcampo id="65b63">#{identifier.to_s}</subcampo>
          <subcampo id="66b63">S</subcampo>
         </field>
      </isomsg>
    EOXML
  end
end
