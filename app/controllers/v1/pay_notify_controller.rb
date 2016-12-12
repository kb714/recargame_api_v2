class V1::PayNotifyController < ApplicationController
  def pp_notify
    data = get_pp_params
    order = data[:PP_ORDER]
    amount = data[:PP_AMOUNT]
    status = data[:PP_STATUS]
    hash = data[:PP_HASH]
    pp_concatenated = "PP_AMOUNT=#{amount}&PP_ORDER=#{order}&PP_STATUS=#{status}"
    digest = OpenSSL::Digest.new('sha256')
    local_hash = OpenSSL::HMAC.hexdigest(digest, self.get_pp_key, pp_concatenated)
    #check hash validity
    if local_hash === hash
      #TRUE NOTIFICATION
      order_model = V1::Order.find_by(order: order)
      if status.to_i == 4 && order_model.status.to_i == 0
        #Generate XML
        xml_document = XmlDocuments.new(
            order_model.amount,
            order_model.identifier,
            order_model.company,
            order_model.order,
            order_model.auth_code
        )
        #CONFIRM PINCENTER
        xml_return = sendXmlPincenterApi(xml_document.confirm.to_s)
        if xml_return == 'ERROR'
          xml_return = sendXmlPincenterApi(xml_document.reconfirm.to_s)
          order_model.response = 'Primer ERROR reintento|'
          if xml_return == 'ERROR'
            order_model.response << xml_return
            order_model.status = 8
            order_model.response << "ERROR AL EFECTUAR LA RECARGA, PAGO CONFIRMADO - REALIZAR RECARGA MANUAL O DEVOLUCION"
            order_model.save
            render json: 'ok', status: 200
          end
        end
        xml_return.xpath("//field[@id='b39']").each do |code|
          if code.content.to_s === '00'
            #OK
            xml_return.xpath("//field[@id='b12']").each do |hour_transaction|
              order_model.hour_transaction = hour_transaction.content.to_s
            end
            xml_return.xpath("//field[@id='b13']").each do |date_transaction|
              order_model.date_transaction = date_transaction.content.to_s
            end
            xml_return.xpath("//subcampo[@id='6Db63']").each do |bonus_amount|
              order_model.bonus_amount = bonus_amount.content.to_i
            end
            xml_return.xpath("//subcampo[@id='6Eb63']").each do |new_balance|
              order_model.new_balance = new_balance.content.to_i
            end
            xml_return.xpath("//subcampo[@id='6Fb63']").each do |validity|
              order_model.validity = validity.content.to_s
            end
            xml_return.xpath("//subcampo[@id='6Gb63']").each do |response|
              order_model.response = response.content.to_s
            end
            xml_return.xpath("//subcampo[@id='9Eb63']").each do |identification|
              order_model.identification = identification.content.to_s
            end
            xml_return.xpath("//subcampo[@id='69b63']").each do |auth_code|
              order_model.auth_code = auth_code.content.to_s
            end
            #SELL SUCCESS
            order_model.status = 4
            order_model.save
            render json: 'ok', status: 200
          else
            #MANUAL
            order_model.status = 8
            order_model.save
            render json: 'ok', status: 200
          end
        end
      elsif status == 6
        #PAY ERROR
        order_model.status = 6
        order_model.save
        render json: 'ok', status: 200
      end
    else
      render json: 'fake', status: 403
    end

  end

  private
  def get_pp_params
    params.permit(:PP_ORDER, :PP_AMOUNT, :PP_STATUS, :PP_HASH)
  end
end
