require 'spec_helper'

describe Article do
  let(:user) { FactoryGirl.create(:user) }
  before { @article = user.articles.build(title: "Article title",
                                          content: "Lorem ipsum")}

  subject { @article }

  it { should respond_to(:title) }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:created_at) }
  it { should respond_to(:description) }
  it { should respond_to(:tag_list) }
  it { should respond_to(:tags) }
  it { should respond_to(:comments) }
  its(:user) { should == user }

  it { should be_valid}

  describe "title length" do
    context "is too long" do
      before { @article.title = "a" * 150 }
      it { should_not be_valid }
    end
    context "is zero" do
      before { @article.title = "" }
      it { should_not be_valid }
    end
  end

  describe "content length" do
    context "is too long" do
     before { @article.content = "a" * 65001 }
     it { should_not be_valid }
    end
  end

  context "when user is not present" do
    before { @article.user_id = nil }
    it { should_not be_valid }
  end

  describe "acessible attributes" do
    it "doesnt allow access to user_id" do
      expect do
        Article.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "order" do
    before do
      @article2 = user.articles.build(title: "Article title",
                                      content: "Lorem ipsum")
      @article2.created_at = 1.minute.since
      @article2.save
      @article.save
    end

    it "sould be descendant by creation date" do
      Article.all.index(@article2).should < Article.all.index(@article)
    end
  end

  describe "description" do
    before do
      @article.content = Faker::Lorem::paragraph(10)
      @article.save
    end
    its(:description) { should_not be_blank }
    its(:description) { should have(300).characters }
  end

  describe "tags validator" do
    before do
      @article.tag_list = ".,."
    end
    it { should_not be_valid }
  end
end
