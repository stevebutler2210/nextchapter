module Api
  module V1
    class ClubsController < BaseController
      before_action :set_club, only: :show

      def index
        clubs = Club.joins(:memberships)
          .where(memberships: { user_id: current_user.id })
          .includes(:memberships)
          .distinct

        render json: { data: clubs.map { |club| club_summary(club) } }
      end

      def show
        render json: { data: club_detail(@club) }
      end

      private

      def set_club
        @club = Club.joins(:memberships)
          .where(memberships: { user_id: current_user.id })
          .includes(memberships: :user)
          .find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Club not found" }, status: :not_found
      end

      def club_summary(club)
        membership = club.memberships.find { |m| m.user_id == current_user.id }
        cycle = club.current_cycle

        {
          id: club.id,
          name: club.name,
          description: club.description,
          role: membership.role,
          current_cycle: cycle ? cycle_summary(cycle) : nil
        }
      end

      def cycle_summary(cycle)
        {
          id: cycle.id,
          state: cycle.state,
          nominations_count: cycle.nominations.size
        }
      end

      def club_detail(club)
        membership = club.memberships.find { |m| m.user_id == current_user.id }
        cycle = club.current_cycle

        {
          id: club.id,
          name: club.name,
          description: club.description,
          role: membership.role,
          members: club.memberships.map { |m|
            { id: m.user.id, name: m.user.name, role: m.role }
          },
          current_cycle: cycle ? cycle_detail(cycle) : nil
        }
      end

      def cycle_detail(cycle)
        nominations = cycle.nominations.includes(
          :votes,
          :user,
          book: { cover_image_attachment: :blob }
        )

        {
          id: cycle.id,
          state: cycle.state,
          winning_book: cycle.winning_nomination ? book_data(cycle.winning_nomination.book) : nil,
          nominations: nominations.map { |n| nomination_data(n) }
        }
      end

      def nomination_data(nomination)
        {
          id: nomination.id,
          book: book_data(nomination.book),
          nominated_by: { id: nomination.user.id, name: nomination.user.name },
          votes_count: nomination.votes.size
        }
      end

      def book_data(book)
        {
          id: book.id,
          title: book.title,
          authors: book.authors,
          cover_url: book.cover_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(book.cover_image, only_path: true) : nil,
          page_count: book.page_count
        }
      end
    end
  end
end
