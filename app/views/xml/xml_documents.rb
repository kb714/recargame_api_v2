class XmlDocuments

  # @return [Object]
  def initialize(amount, identifier, company, order)
    t = Time.now - 10800
    @validate = Nokogiri::Slop <<-EOXML
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
          <subcampo id="20b63">#{order.to_s}</subcampo>
          <subcampo id="61b63">#{company.to_s}</subcampo>
          <subcampo id="65b63">#{identifier.to_s}</subcampo>
          <subcampo id="66b63">S</subcampo>
         </field>
      </isomsg>
    EOXML
  end

  attr_accessor(:validate)
end