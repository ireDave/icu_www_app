class Failure < ActiveRecord::Base
  include Pageable

  IGNORE = %w[ActiveRecord::RecordNotFound ActionController::UnknownFormat]

  scope :ordered, -> { order(created_at: :desc) }

  before_create :normalize_details

  def self.examine(payload)
    name = payload[:exception].first
    unless IGNORE.include?(name)
      Failure.create!(name: name, details: payload.dup)
    end
  end

  def self.search(params, path)
    matches = ordered
    matches = matches.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
    matches = matches.where("details LIKE ?", "%#{params[:details]}%") if params[:details].present?
    paginate(matches, params, path)
  end

  def snippet
    details.to_s.gsub(/\n/, " ").truncate(50)
  end

  private

  def normalize_details
    if details.is_a?(Hash)
      if details[:exception].is_a?(Array) && details[:exception].size == 2
        exception = details.delete(:exception)
        details[:name] = exception.first
        details[:message] = exception.last
      end
      self.details = details.map{ |key,val| "#{key}: #{val}" }.sort.join("\n")
    end
  end
end