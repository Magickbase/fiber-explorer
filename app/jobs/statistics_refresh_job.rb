class StatisticsRefreshJob
  include Sidekiq::Job

  sidekiq_options queue: :low

  def perform
    created_timestamp = Time.current.beginning_of_day.to_i
    stat = Statistic.find_or_create_by!(created_timestamp:)
    stat.reset_all!
  end
end
