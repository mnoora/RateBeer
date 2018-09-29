class User < ApplicationRecord
  include RatingAverage

  PASSWORD_FORMAT = /\A
  (?=.*\d)           # Must contain a digit
  (?=.*[A-Z])        # Must contain an upper case character
/x

  has_secure_password

  validates :username, uniqueness: true,
                       length: { in: 3..30 }
  has_many :ratings, dependent: :destroy
  has_many :beers, through: :ratings
  has_many :memberships, dependent: :destroy
  has_many :beer_clubs, through: :memberships

  validates :password, length: { minimum: 4 },
                       format: { with: PASSWORD_FORMAT }

  def favorite_beer
    return nil if ratings.empty?

    ratings.order(score: :desc).limit(1).first.beer
  end

  def favorite_style
    return nil if ratings.empty?

    highest_average = 0.0
    favorite = nil
    compare_average_ratings_style(favorite, highest_average)
  end

  def average_ratings_style(sty)
    sum_of_ratings = ratings.select{ |x| x.beer.style == sty }.map(&:score).inject(0, &:+)
    number_of_ratings = ratings.select{ |x| x.beer.style == sty }.count.to_f
    rating_ave = sum_of_ratings / number_of_ratings
    rating_ave
  end

  def compare_average_ratings_style(favorite, highest_average)
    ratings.map{ |b| b.beer.style }.uniq.each do |sty|
      rating_ave = average_ratings_style(sty)
      if rating_ave > highest_average
        highest_average = rating_ave
        favorite = sty
      end
    end
    favorite
  end

  def favorite_brewery
    return nil if ratings.empty?

    favorite = nil
    highest_average = 0.0
    compare_average_ratings_brewery(favorite, highest_average)
  end

  def average_ratings_brewery(bre)
    sum_of_ratings = ratings.select{ |x| x.beer.brewery.id == bre.id }.map(&:score).inject(0, &:+)
    number_of_ratings = ratings.select{ |x| x.beer.brewery.id == bre.id }.count.to_f
    rating_ave = sum_of_ratings / number_of_ratings
    rating_ave
  end

  def compare_average_ratings_brewery(favorite, highest_average)
    ratings.map{ |b| b.beer.brewery }.uniq.each do |bre|
      rating_ave = average_ratings_brewery(bre)
      if rating_ave > highest_average
        highest_average = rating_ave
        favorite = bre
      end
    end
    favorite.name
  end
end
