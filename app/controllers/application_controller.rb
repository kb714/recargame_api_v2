class ApplicationController < ActionController::API

  def get_pp_key
    '74h3P47WS7Y2IpzkB39IOJBNmDRKURi1Wz5MDcJw'
  end

  def get_pp_shop
    '399'
  end

  def sendXmlPincenterApi(xml_doc)
    host = '200.111.44.187'
    port = 7987
    timeout = 10

    s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    s.connect(Socket.pack_sockaddr_in(port, host))
    # s << xml_doc
    rs, = IO.select([s], [], [], timeout)
    if rs
      s.write(xml_doc)
      response = s.readpartial(4096)
      s.close
      Nokogiri.XML response
    else
      s.close
      'ERROR'
    end
    #begin
    #  Timeout.timeout(20) do
    #    begin
    #      #Rails.env.development
    #      hostname = '200.111.44.187'
    #      port = 7987
    #      socket = TCPSocket.open(hostname, port)
    #      socket << xml_doc
    #      response = socket.readpartial 4096
    #      socket.close
    #      Nokogiri.XML response
    #    rescue Timeout::Error => exc
    #      'ERROR'
    #    rescue Errno::ETIMEDOUT => exc
    #      'ERROR'
    #    rescue EOFError
    #      'ERROR'
    #    rescue
    #      'ERROR'
    #    end
    #  end
    #rescue Timeout::Error
    #  socket.close
    #  'ERROR'
    #end
  end

  def getCompany name
    case name
    when 'entel' then '01'
    when 'movistar' then '02'
    when 'claro' then '03'
    when 'gtd' then '08'
    when 'directv' then '09'
    when 'clarotv' then '10'
    when 'wom' then '11'
    when 'vtr' then '12'
    when 'claro-multimedia' then '13'
    when 'virgin' then '14'
    when 'gtel' then '16'
    when 'falabella' then '17'
    when 'claro-fijo' then '18'
    else '00'
    end
  end
end
