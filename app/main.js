import { GoogleGenerativeAI } from "@google/generative-ai";
import './style.css';

const GEN_API_KEY = import.meta.env.VITE_GEN_AI_KEY;

const genAI = new GoogleGenerativeAI(GEN_API_KEY);
const model = genAI.getGenerativeModel({
  model: "gemini-pro",
  generationConfig: {
    maxOutputTokens: 100,
  },
});
const chat = model.startChat({
  generationConfig: {
    maxOutputTokens: 100,
  },
});

const singleForm = document.querySelector('form#single');

singleForm.onsubmit = async (ev) => {
  ev.preventDefault();
  const singleOutput = document.querySelector('form#single+.output');
  const singleInput = document.querySelector('form#single input[name="prompt"]');
  singleOutput.textContent = 'Generating...';
  // Assemble the prompt by combining pre-determined text
  // "tell me a story" with what the user entered in the text field
  const subject = singleInput.value;
  const prompt = `Tell me a very short story about: ${subject}`;

  try {
    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
    });
    const response = result.response.text();
    singleOutput.textContent = response
    chat.sendMessage("When asked more questions, continue talking about this story.")
    clearChatMessages()
  }
  catch (e) {
    singleOutput.textContent = e.message;
  }
  singleInput.setAttribute('placeholder', subject);
  singleInput.value = '';
};

const chatForm = document.querySelector('form#chat');

chatForm.onsubmit = async (ev) => {
  ev.preventDefault();
  const chatInput = document.querySelector('form#chat input[name="chat"]');
  // Assemble the prompt by combining pre-determined text
  // "tell me a story" with what the user entered in the text field
  const message = chatInput.value;
  addChatMessage(message, "end");
  showPendingChat();
  try {
    const result = await chat.sendMessage(message);
    const response = result.response.text()
    addChatMessage(response, "start");
  }
  catch (e) {
    addChatMessage(e.message, "start");
  }
  chatInput.value = '';
  hidePendingChat();
};

function showPendingChat(){
  document.querySelector(".chat-pending").style.visibility = "visible";
}

function hidePendingChat(){
  document.querySelector(".chat-pending").style.visibility = "hidden";
}

function addChatMessage(text, textAlign) {
  const chatHistory = document.querySelector('div.chat-history');
  const p = document.createElement('p')
  p.textContent = text
  p.style.textAlign = textAlign
  p.classList.add('output')
  chatHistory.appendChild(p)
}

function clearChatMessages() {
  const chatHistory = document.querySelector('div.chat-history');
  while (chatHistory.hasChildNodes()) {
    chatHistory.removeChild(chatHistory.firstChild)
  }
}