require_relative 'aa_questions'

class ModelBase
  C_TO_TABLE = {
    'QuestionFollow' => 'question_follows',
    'QuestionLike' => 'question_likes',
    'Question' => 'questions',
    'Reply' => 'replies',
    'User' => 'users'
  }.freeze

  def self.find_by_id(id)
    table = C_TO_TABLE[name]

    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL

    return nil if data.empty?

    new(data.first)
  end

  def self.all
    table = C_TO_TABLE[name]

    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL

    return nil if data.empty?

    data.map { |datum| new(datum) }
  end
end
