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

  def save
    @id.nil? ? insert : update
  end

  def insert
    table, attrs, values = obj_attrs
    attr_str = attrs.map { |attr| attr.to_s[1..-1] }.join(', ')
    q_marks = ('?' * values.length).split('').join(', ')

    QuestionsDatabase.instance.execute(<<-SQL, *values)
      INSERT INTO
        #{table} (#{attr_str})
      VALUES
        (#{q_marks})
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    table, attrs, values = obj_attrs
    attr_val_str = attrs.map { |attr| attr.to_s[1..-1] }.join(' = ?, ') + ' = ?'

    QuestionsDatabase.instance.execute(<<-SQL, *values, @id)
      UPDATE
        #{table}
      SET
        #{attr_val_str}
      WHERE
        id = ?
    SQL
  end

  def obj_attrs
    table = C_TO_TABLE[self.class.name]
    attrs = instance_variables
    values = attrs.map { |attr| instance_variable_get(attr) }
    [table, attrs, values]
  end
end
