require_relative 'aa_questions'
require_relative 'model_base'

class User < ModelBase
  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    return nil if data.empty?

    data.map { |datum| User.new(datum) }
  end

  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(question_likes.user_id) AS FLOAT) / COUNT(DISTINCT questions.id) AS avg_value
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = ?
    SQL

    data.first['avg_value']
  end
end
