class V1::VoucherController < ApplicationController

  def show
    data = get_voucher_params
    voucher = V1::Order.find_by(:order => data[:order])
    if voucher
      if voucher.status != 4
        return render json: 'no aprobada', status: 301
      end
      c11 = '64'
      sc14 = '361988'
      sc15 = '000381'
      sc20 = '14725836'
      case voucher.company
        when '01'
          #Entel
          response = {
              company: 'ENTEL',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '02'
          #Movistar
          response = {
              company: 'MOVISTAR',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '03'
          #Claro
          response = {
              company: 'CLARO',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code,
              new_balance: voucher.new_balance,
              bonus_amount: voucher.bonus_amount
          }
        when '08'
          #GTD
          response = {
              company: 'GTD',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code,
              new_balance: voucher.new_balance
          }
        when '09'
          #DirecTV
          response = {
              company: 'DIRECTV',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code,
              bonus_amount: voucher.bonus_amount
          }
        when '10'
          #ClaroTV
          response = {
              company: 'CLAROTV',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code,
              new_balance: voucher.new_balance
          }
        when '11'
          #Wom
          response = {
              company: 'WOM',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '12'
          #VTR
          response = {
              company: 'VTR',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code,
              new_balance: voucher.new_balance,
              validity: voucher.validity
          }
        when '13'
          #Claro Multimedia
          response = {
              company: 'CLAROMULTIMEDIA',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '14'
          #Virgin
          response = {
              company: 'VIRGIN',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '16'
          #Gtel
          response = {
              company: 'GTEL',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '17'
          #Falabella
          response = {
              company: 'FALABELLA',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        when '18'
          #Claro fijo inalambrico
          response = {
              company: 'CLAROFIJOINALAMBRICO',
              date_transaction: Date.strptime(voucher.date_transaction.to_s, '%Y%m%d').strftime('%d/%m/%Y'),
              hour_transaction: Time.strptime(voucher.hour_transaction.to_s, '%H%M%S').strftime('%H:%M:%S'),
              order: voucher.order,
              commerce: c11,
              local: sc14,
              terminal: sc15,
              seller: sc20,
              amount: voucher.amount,
              identifier: voucher.identifier,
              auth_code: voucher.auth_code
          }
        else
          return render json: 'not found', status: 404
      end
      render json: response
    else
      render json: 'not found', status: 404
    end
  end

  private
  def get_voucher_params
    params.permit(:order)
  end

end
