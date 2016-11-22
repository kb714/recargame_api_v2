class ApplicationController < ActionController::API

  def get_pp_key
    '74h3P47WS7Y2IpzkB39IOJBNmDRKURi1Wz5MDcJw'
  end

  def get_pp_shop
    '399'
  end

  def sendXmlPincenterApi(xml_doc)
    hostname = '200.111.44.187'
    port = 7987
    timeout = 20
    #begin
    #  Timeout.timeout(20) do
    #    begin
    #      #Rails.env.development
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
    addr = Socket.getaddrinfo(hostname, nil)
    sockaddr = Socket.pack_sockaddr_in(port, hostname)

    Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0).tap do |socket|
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

      begin
        # Initiate the socket connection in the background. If it doesn't fail
        # immediatelyit will raise an IO::WaitWritable (Errno::EINPROGRESS)
        # indicating the connection is in progress.
        socket.connect_nonblock(sockaddr)

      rescue IO::WaitWritable
        # IO.select will block until the socket is writable or the timeout
        # is exceeded - whichever comes first.
        if IO.select(nil, [socket], nil, timeout)
          begin
            # Verify there is now a good connection
            socket.connect_nonblock(sockaddr)
            socket << xml_doc
            response = socket.readpartial 4096
            socket.close
            Nokogiri.XML response
          rescue Errno::EISCONN
            # Good news everybody, the socket is connected!
            socket.close
            'ERROR'
          rescue
            # An unexpected exception was raised - the connection is no good.
            socket.close
            'ERROR'
          end
        else
          # IO.select returns nil when the socket is not ready before timeout
          # seconds have elapsed
          socket.close
          'ERROR'
        end
      end
    end
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
