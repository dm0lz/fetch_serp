class ApiSession < ApplicationRecord
  belongs_to :user
  validates :endpoint, presence: true
  after_create :set_credit

  private
  def set_credit
    user.update!(api_credit: user.api_credit - api_session_cost)
  end

  def api_session_cost
    request_params["search_engine"] ? api_endpoint_credit[request_params["search_engine"]] : 2
  end

  def api_endpoint_credit
    {
      "duckduckgo" => 1,
      "bing" => 1,
      "yahoo" => 2,
      "yandex" => 2,
      "google" => 3
    }
  end
end
