class Desire < ApplicationRecord
  #enum action: [:Promoção, :ProdutoServiço, :Slide_para_Sistema_Luqy]
  enum action: %w(Divulgar_Promoção Divulgar_Produto/Serviço Divulgar_em_TV)
  enum status: %w(Em_Analise Aprovado)
  # status = {}
  # status[:analise] = "Em Analise"
  # status[:aprovado] = "Aprovado!"
  # enum status: status

  mount_uploader :img1, PhotoUploader
  mount_uploader :img2, PhotoUploader
  mount_uploader :img3, PhotoUploader

  belongs_to :user
  belongs_to :company

  before_create :credit_user

  after_create :set_code_number
  after_create :send_email_desejo

  after_save do
    set_code_number if self.title.exclude?("#")
  end

  def credit_user
    #u = self.user_id
    if self.user.credit <= 0
      #false
      throw(:abort)
    else
      self.user.credit -=1
      self.user.save
    end
  end

  def set_code_number
    self.update_column(:title, "#{title} ##{id}")
  end

  def send_email_desejo
    UserMailer.email_desejo(self.user, self).deliver
    UserMailer.email_admin.deliver
  end
end
