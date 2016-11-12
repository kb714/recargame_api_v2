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
        #CONFIRM PINCENTER
        xml_return = sendXmlPincenterApi(confirm(order_model.amount, order_model.identifier, order_model.company, order_model.auth_code))
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
            #PAY SUCCESS
            order_model.status = 4
            order_model.save
            render json: 'ok', status: 200
          else
            #RETRY
            xml_return = sendXmlPincenterApi(re_confirm(order_model.amount, order_model.identifier, order_model.company, order_model.auth_code))
            xml_return.xpath("//field[@id='b39']").each do |recode|
              if recode.content.to_s === '00'
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
                #PAY SUCCESS
                order_model.status = 4
                order_model.save
                render json: 'ok', status: 200
              else
                #RETRY
                #PAY ERROR
                order_model.status = 6
                order_model.response = 'reintento error=' << recode.content.to_s
                order_model.save
                render json: 'ok', status: 200
              end
            end
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

  #pincenter XML
  def confirm(amount, identifier, company, auth_code)
    t = Time.now
    return Nokogiri::Slop <<-EOXML
      <isomsg>
        <field id="b0">0300</field>
        <field id="b3">520000</field>
        <field id="b4">#{amount.to_s}</field>
        <field id="b11">000049</field>
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
          <subcampo id="15b63">999999</subcampo>
          <subcampo id="20b63">14725836</subcampo>
          <subcampo id="61b63">#{company.to_s}</subcampo>
          <subcampo id="65b63">#{identifier.to_s}</subcampo>
          <subcampo id="66b63">S</subcampo>
          <subcampo id="69b63">#{auth_code.to_s}</subcampo>
        </field>
      </isomsg>
    EOXML
  end
  def re_confirm(amount, identifier, company, auth_code)
    t = Time.now
    return Nokogiri::Slop <<-EOXML
      <isomsg>
        <field id="b0">0380</field>
        <field id="b3">520000</field>
        <field id="b4">#{amount.to_s}</field>
        <field id="b11">000049</field>
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
          <subcampo id="15b63">999999</subcampo>
          <subcampo id="20b63">14725836</subcampo>
          <subcampo id="61b63">#{company.to_s}</subcampo>
          <subcampo id="65b63">#{identifier.to_s}</subcampo>
          <subcampo id="66b63">S</subcampo>
          <subcampo id="69b63">#{auth_code.to_s}</subcampo>
        </field>
      </isomsg>
    EOXML
  end
end
