Rails.application.routes.draw do
  root 'v1/validate#index'
  namespace :v1 do
    post 'validate-operation' => 'validate#validate_operation'
    post 'validate-pay' => 'validate#validate_pay'
    post 'pp_notify' => 'pay_notify#pp_notify'
  end
end
