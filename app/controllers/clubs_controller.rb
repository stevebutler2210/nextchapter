class ClubsController < ApplicationController
  before_action :club_turbo_frames_guard, only: [ :new, :create ]
  before_action :set_club, only: [ :show, :edit, :update, :destroy ]
  before_action :require_club_owner!, only: [ :edit, :update, :destroy ]

  def index
    @clubs = clubs_for_current_user
  end

  def new
    @club = Club.new
  end

  def show
    @memberships = @club.memberships.includes(:user)
    @club_owner = @club.owned_by?(Current.user)
    @invite_token = @club.signed_id(expires_in: 1.week)
  end

  def edit
  end

  def update
    if @club.update(club_params)
      redirect_to club_path(@club)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @club.destroy!
    redirect_to clubs_path, status: :see_other
  end

  def create
    @club = Club.new(club_params.merge(created_by: Current.user))

    ActiveRecord::Base.transaction do
      @club.save!
      @club.memberships.create!(user: Current.user, role: :owner)
    end

    @clubs = clubs_for_current_user
    render :index
  rescue ActiveRecord::RecordInvalid => error
    unless error.record.equal?(@club)
      @club.errors.add(:base, error.record.errors.full_messages.to_sentence)
    end

    render :new, status: :unprocessable_entity
  end

  private
    def club_params
      params.expect(club: [ :name, :description ])
    end

    def club_turbo_frames_guard
      redirect_to clubs_path unless turbo_frame_request?
    end

    def set_club
      @club = clubs_for_current_user.find(params[:id])
    end

    def require_club_owner!
      head :forbidden unless @club.owned_by?(Current.user)
    end

    def clubs_for_current_user
      Club.joins(:memberships)
        .where(memberships: { user_id: Current.user.id })
        .distinct
    end
end
