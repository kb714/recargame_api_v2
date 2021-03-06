class V1::Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: Integer
  field :status, type: Integer
  field :order, type: String
  field :email, type: String
  field :identifier, type: String
  field :amount, type: Integer
  field :company, type: String
  field :auth_code, type: String
  #response pincenter
  field :id_transaction, type: String
  field :bonus_amount, type: Integer
  field :new_balance, type: Integer
  field :validity, type: String
  field :response, type: String
  field :identification, type: String
  field :hour_transaction, type: String
  field :date_transaction, type: String

  validates :status, presence: true,
            :numericality => {
                :only_integer => true
            }
  #validates :order, presence: true
  validates :identifier, presence: true,
            :numericality => {
                :only_integer => true
            }
  validates :amount, presence: true,
            :numericality => {
                :only_integer => true
            }
  validates :company, presence: true
  #validates :email, presence: true

  before_create :setOrderNumber

  def build(company, data)
    self.status = 0
    self.identifier = data[:identifier]
    self.amount = data[:amount]
    self.company = company.to_s
    self.email = data[:email]
  end

  protected
  def setOrderNumber
    order = getOrderNumber
    self.order = order

    while V1::Order.where(:order => order).exists?
      self.order = order
    end
  end

  private
  def getOrderNumber
    rand(11 .. 99).to_s << Time.now.strftime('%m%d').to_s << rand(1111 .. 9999).to_s
  end
end
