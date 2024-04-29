<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Hw3.aspx.cs" Inherits="HW3.Hw3" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hangwoman Game</title>
    <link href="https://cdn.jsdelivr.net/npm/bootswatch@5.2.3/dist/flatly/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js" integrity="sha384-w76AqPfDkMBDXo30jS1Sgez6pr3x5MlQ1ZAGC+nuZB+EYdgRZgiwxhTBTkF7CXvN" crossorigin="anonymous"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito&display=swap" rel="stylesheet">
    <style>
        .button-space { margin-right: 10px; }
        .button-group-spacing { margin-top: 20px; }
        .top-right { position: absolute; right: 10px; top: 10px; font-size: 1.5em; display: flex; align-items: center; }
        .refresh-btn { margin-left: 15px; }
        .space-between-sections { margin-top: 20px; }
        .win-image { display: none; width: 100%; max-width: 300px; margin-top: 20px; }

        #keyboard {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
        }

        button {
            padding: 10px 15px;
            margin: 5px;
            border: none;
            background-color: #007BFF;
            color: white;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
        }

        button:hover {
            background-color: #0056b3;
        }
    </style>
    <script type="text/javascript">
        function showEndGameAnimationAndSound() {
            var audio = new Audio('/Sounds/GameOver.Wav');
            audio.play();
            setTimeout(function () {
                var correctAnswer = document.getElementById('<%= CorrectAnswerHiddenField.ClientID %>').value;
                alert("The correct answer is: " + correctAnswer);
            }, 2000);
        }

        function playWinSoundAndShowImage() {
            var audio = new Audio('/Sounds/GameWin.Wav');
            audio.play();
            document.getElementById('<%= WinImage.ClientID %>').style.display = 'block';
        }

        function refreshPage() {
            window.location.reload();
        }

        document.addEventListener("DOMContentLoaded", function () {
            const englishAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const turkishExtras = "ÇĞIİÖŞÜ";
            const completeAlphabet = englishAlphabet + turkishExtras;
            const keyboardContainer = document.getElementById("keyboard");
            const guessTextBox = document.getElementById('<%= GuessTextBox.ClientID %>'); // Get the ASP.NET TextBox control

            // Create buttons for each letter
            completeAlphabet.split('').forEach(letter => {
                let button = document.createElement('button');
                button.textContent = letter;
                button.addEventListener('click', function () {
                    guessTextBox.value += this.textContent; // Append the letter to the TextBox value
                });
                keyboardContainer.appendChild(button);
            });
        });
    </script>
</head>
<body style="background-image:url('Background.jpg'); background-size: cover;">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container d-flex justify-content-center align-items-center" style="height: 100vh;">
            <asp:MultiView ID="Multiview" runat="server" ActiveViewIndex="0">
                <!-- Main View -->
                <asp:View ID="ViewID0" runat="server">
                    <div class="text-center">
                        <img src="images/Hangmanlogo.png" style="width: 400px; background-color: rgba(103,140,127,0.5); border-radius: 50% 10% 10% 30%; border: solid 5px" />
                        <br /><br />
                        <asp:Button ID="StartBTN" CssClass="btn btn-success" runat="server" Text="Start" Width="200px" Height="100px" Font-Size="XX-Large" OnClick="StartGame_Click" />
                        <br /><br />
                        <asp:Button ID="ManageWordsBTN" CssClass="btn btn-warning" runat="server" Text="Manage Words" Width="200px" Height="50px" OnClick="ShowManageWords_Click" />
                    </div>
                </asp:View>

                <!-- Manage Words View -->
                <asp:View ID="ViewID1" runat="server">
                    <div class="text-center">
                        <asp:Button ID="BackBTN" CssClass="btn btn-danger" runat="server" Text="Back to Main Menu" OnClick="BackToMain_Click" />
                        <h2>Add or Remove Words</h2>
                        <asp:TextBox ID="NewWordName" runat="server" CssClass="form-control" Placeholder="Enter new word" />
                        <asp:TextBox ID="NewWordQuestion" runat="server" CssClass="form-control" TextMode="MultiLine" Placeholder="Enter question for the new word" />
                        <asp:Button ID="AddWordButton" runat="server" Text="Add Word" OnClick="AddWordButton_Click" CssClass="btn btn-primary" />
                        <hr />
                        <asp:ListBox ID="WordList" runat="server" Width="100%" OnSelectedIndexChanged="WordList_SelectedIndexChanged" AutoPostBack="true" />
                        <asp:Label ID="SelectedWordLabel" runat="server" Text="Select a word to see details here." CssClass="alert alert-info" />
                        <asp:Button ID="DeleteSelectedWordButton" runat="server" Text="Delete Selected Word" OnClick="DeleteSelectedWordButton_Click" CssClass="btn btn-danger" />
                    </div
                </asp:View>

                <!-- Game View -->
                <asp:View ID="ViewID2" runat="server">
                    <div class="text-center">
                        <h2 class="space-between-sections">Answer the Following Question</h2><br />
                        <asp:Label ID="WordLabel" runat="server" CssClass="alert alert-success question-spacing" Text="Question will appear here" />
                        <br /><br />
                        <!-- Hangwoman Image Controls -->
                        <asp:Image ID="ImagePart1" runat="server" ImageUrl="~/Images/011.png" Visible="False" />
                        <asp:Image ID="ImagePart2" runat="server" ImageUrl="~/Images/02.png" Visible="False" />
                        <asp:Image ID="ImagePart3" runat="server" ImageUrl="~/Images/03.png" Visible="False" />
                        <asp:Image ID="ImagePart4" runat="server" ImageUrl="~/Images/04.png" Visible="False" />
                        <asp:Image ID="ImagePart5" runat="server" ImageUrl="~/Images/05.png" Visible="False" />
                        <asp:Image ID="ImagePart6" runat="server" ImageUrl="~/Images/06.png" Visible="False" />
                         <asp:Image ID="ImagePart7" runat="server" ImageUrl="~/Images/07.png" Visible="False" />
                        <asp:Image ID="ImagePart8" runat="server" ImageUrl="~/Images/08.png" Visible="False" />
                        <!-- Win Image -->
                        <asp:Image ID="WinImage" runat="server" ImageUrl="~/Images/win.png" CssClass="win-image" />
                        <br />
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <ContentTemplate>
                                <div class="top-right">
                                    <asp:Label ID="TimerLabel" runat="server" CssClass="alert alert-warning" Text="30" />
                                    <button type="button" onclick="refreshPage()" class="btn btn-info btn-sm refresh-btn"><i class="fa fa-refresh"></i></button>
                                </div>
                                <asp:Timer ID="GameTimer" runat="server" Interval="1000" OnTick="GameTimer_Tick" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:TextBox ID="GuessTextBox" runat="server" CssClass="form-control" Placeholder="Enter your guess here" AutoPostBack="false" />
                        <div class="btn-group button-group-spacing" role="group" aria-label="Game Buttons">
                            <asp:Button ID="SubmitGuessButton" runat="server" Text="Submit Guess" CssClass="btn btn-primary button-space" OnClick="SubmitGuess_Click" />
                            <asp:Button ID="BackBTN2" CssClass="btn btn-danger" runat="server" Text="Back to Main Menu" OnClick="BackToMain_Click" />
                        </div>
                        <asp:Label ID="FeedbackLabel" runat="server" CssClass="alert alert-info" Visible="false" />
                        <br />
                        <asp:HiddenField ID="CorrectAnswerHiddenField" runat="server" />
                        <br />
                        <div>
                            <div id="keyboard">
                                <!-- Buttons will be generated by JavaScript -->
                            </div>
                        </div>
                    </div>
                </asp:View>
            </asp:MultiView>
        </div>
    </form>
</body>
</html>
