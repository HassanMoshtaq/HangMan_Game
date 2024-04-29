using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace HW3
{
    public partial class Hw3 : System.Web.UI.Page
    {
        private string xmlFilePath => Server.MapPath("WordsList.xml");

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadWordsFromXML();
                Session["IncorrectGuesses"] = 0;
            }
        }

        private void LoadWordsFromXML()
        {
            XDocument doc = XDocument.Load(xmlFilePath);
            var words = doc.Descendants("Word").Select(x => new ListItem
            {
                Value = x.Element("Name").Value,
                Text = x.Element("Name").Value + " - " + x.Element("Question").Value
            }).ToList();

            WordList.Items.Clear();
            WordList.Items.AddRange(words.ToArray());
        }

        protected void AddWordButton_Click(object sender, EventArgs e)
        {
            XDocument doc = XDocument.Load(xmlFilePath);
            XElement newWord = new XElement("Word",
                new XElement("Name", NewWordName.Text),
                new XElement("Question", NewWordQuestion.Text));

            doc.Root.Add(newWord);
            doc.Save(xmlFilePath);
            LoadWordsFromXML();
            NewWordName.Text = "";
            NewWordQuestion.Text = "";
        }

        protected void DeleteSelectedWordButton_Click(object sender, EventArgs e)
        {
            XDocument doc = XDocument.Load(xmlFilePath);
            var selectedItem = doc.Root.Elements("Word").FirstOrDefault(x => x.Element("Name").Value == WordList.SelectedValue);
            if (selectedItem != null)
            {
                selectedItem.Remove();
                doc.Save(xmlFilePath);
                LoadWordsFromXML();
                SelectedWordLabel.Text = "Word deleted successfully.";
            }
        }

        protected void WordList_SelectedIndexChanged(object sender, EventArgs e)
        {
            XDocument doc = XDocument.Load(xmlFilePath);
            var selectedWord = doc.Descendants("Word").FirstOrDefault(x => x.Element("Name").Value == WordList.SelectedValue);

            if (selectedWord != null)
            {
                SelectedWordLabel.Text = $"Name: {selectedWord.Element("Name").Value}, Question: {selectedWord.Element("Question").Value}";
            }
        }

        protected void StartGame_Click(object sender, EventArgs e)
        {
            Multiview.ActiveViewIndex = 2;
            LoadRandomQuestion();
        }

        private void LoadRandomQuestion()
        {
            XDocument doc = XDocument.Load(xmlFilePath);
            var words = doc.Descendants("Word").ToList();
            Random rand = new Random();
            var randomWord = words[rand.Next(words.Count)];
            string word = randomWord.Element("Name").Value;
            string question = randomWord.Element("Question").Value;

            ViewState["CorrectWord"] = word;
            CorrectAnswerHiddenField.Value = word;
            WordLabel.Text = "Answer the question: " + question;
            TimerLabel.Text = "30";
            GameTimer.Enabled = true;
            Session["IncorrectGuesses"] = 0;
            ResetHangwomanImages();
        }

        protected void SubmitGuess_Click(object sender, EventArgs e)
        {
            string correctWord = ViewState["CorrectWord"] as string;
            if (GuessTextBox.Text.Trim().Equals(correctWord, StringComparison.OrdinalIgnoreCase))
            {
                FeedbackLabel.Text = "Congratulations! You answered correctly.";
                FeedbackLabel.CssClass = "alert alert-success";
                FeedbackLabel.Visible = true;
                GameTimer.Enabled = false;
                ScriptManager.RegisterStartupScript(this, GetType(), "playWinSoundAndShowImage", "playWinSoundAndShowImage();", true);
            }
            else
            {
                int incorrectGuesses = (int)Session["IncorrectGuesses"];
                incorrectGuesses++;
                Session["IncorrectGuesses"] = incorrectGuesses;
                UpdateHangwomanImage(incorrectGuesses);
                FeedbackLabel.Text = "Incorrect, try again!";
                FeedbackLabel.CssClass = "alert alert-danger";
                FeedbackLabel.Visible = true;
            }
            GuessTextBox.Text = "";
        }

        private void UpdateHangwomanImage(int guesses)
        {
            ImagePart1.Visible = guesses >= 1;
            ImagePart2.Visible = guesses >= 2;
            ImagePart3.Visible = guesses >= 3;
            ImagePart4.Visible = guesses >= 4;
            ImagePart5.Visible = guesses >= 5;
            ImagePart6.Visible = guesses >= 6;
            ImagePart7.Visible = guesses >= 7;
            ImagePart8.Visible = guesses >= 8;
        }

        private void ResetHangwomanImages()
        {
            ImagePart1.Visible = false;
            ImagePart2.Visible = false;
            ImagePart3.Visible = false;
            ImagePart4.Visible = false;
            ImagePart5.Visible = false;
            ImagePart6.Visible = false;
            ImagePart7.Visible = false;
            ImagePart8.Visible = false;
        }

        protected void GameTimer_Tick(object sender, EventArgs e)
        {
            int timeLeft = Convert.ToInt32(TimerLabel.Text) - 1;
            if (timeLeft <= 0)
            {
                GameTimer.Enabled = false;
                TimerLabel.Text = "Time's up!";
                FeedbackLabel.Text = "Sorry, time is up!";
                FeedbackLabel.CssClass = "alert alert-danger";
                FeedbackLabel.Visible = true;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "endGameEffects", "showEndGameAnimationAndSound();", true);
            }
            else
            {
                TimerLabel.Text = timeLeft.ToString();
            }
        }

        protected void BackToMain_Click(object sender, EventArgs e)
        {
            Multiview.ActiveViewIndex = 0;
        }

        protected void ShowManageWords_Click(object sender, EventArgs e)
        {
            Multiview.ActiveViewIndex = 1;
            LoadWordsFromXML();
        }
    }
}
