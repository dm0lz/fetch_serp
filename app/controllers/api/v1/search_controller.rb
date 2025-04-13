class Api::V1::SearchController < Api::V1::BaseController
  # @summary Get search engine results
  # @auth [bearer]
  # @parameter query(query) [!String] The query to search
  # @parameter search_engine(query) [String] The search engine to use. Supported values: google, bing, yahoo, duckduckgo, yandex
  # @parameter country(query) [String] The country to search from. For google limited to us, fr, de, es
  # @parameter pages_number(query) [Integer] The number of pages to search
  # @response Validation errors(401) [Hash{error: String}]
  # @response Validation errors(403) [Hash{error: String}]
  # @response Validation errors(422) [Hash{error: String}]
  def index
    allowed_search_engines = %w[google bing yahoo duckduckgo yandex]
    allowed_countries = [ "us", "fr", "de", "es" ]

    unless params.permit(:query)[:query]
      return render json: { error: "query is required" }, status: :unprocessable_entity
    end

    if serp_params[:pages_number] && !serp_params[:pages_number].to_i.positive?
      return render json: { error: "pages number must be a positive integer" }, status: :unprocessable_entity
    end

    if serp_params[:search_engine] && !allowed_search_engines.include?(serp_params[:search_engine])
      return render json: { error: "Invalid search_engine. Allowed values: #{allowed_search_engines.join(', ')}" }, status: :unprocessable_entity
    end

    if serp_params[:country]
      if serp_params[:search_engine] == "google"
        return render json: { error: "Invalid country. Allowed values with google search engine : #{allowed_countries.join(', ')}" }, status: :unprocessable_entity if !allowed_countries.include?(serp_params[:country])
      end
    end

    serp = SearchEngine::QueryService.new(
      search_engine: serp_params[:search_engine] || "duckduckgo",
      country: serp_params[:country] || "us",
      pages_number: serp_params[:pages_number] || 3
    ).call(params.expect(:query))
    @error = serp["error"] rescue nil
    @web_pages = Scraper::WebPagesService.new(serp.map { |result| result["url"] }).call unless @error
  end

  private
  def serp_params
    params.permit(:search_engine, :pages_number, :country).to_h.compact
  end
end
