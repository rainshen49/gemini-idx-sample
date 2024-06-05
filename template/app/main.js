import { GoogleGenerativeAI, HarmBlockThreshold, HarmCategory } from "@google/generative-ai";
import Base64 from 'base64-js';
import MarkdownIt from 'markdown-it';
import { maybeShowApiKeyBanner } from './gemini-api-banner';
import './style.css';

// 🔥 FILL THIS OUT FIRST! 🔥
// 🔥 GET YOUR GEMINI API KEY AT 🔥
// 🔥 https://makersuite.google.com/app/apikey 🔥
const GEN_API_KEY = import.meta.env.VITE_GEN_AI_KEY ?? 'TODO';

const genAI = new GoogleGenerativeAI(GEN_API_KEY);
const imageModel = genAI.getGenerativeModel({
  model: "gemini-pro-vision",
  safetySettings: [
    {
      category: HarmCategory.HARM_CATEGORY_HARASSMENT,
      threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    },
  ],
});
const textModel = genAI.getGenerativeModel({
  model: "gemini-pro",
});
const chat = textModel.startChat({
  safetySettings: [
    {
      category: HarmCategory.HARM_CATEGORY_HARASSMENT,
      threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    },
  ],
});
const md = new MarkdownIt();

const imageForm = document.querySelector('form#image');

imageForm.onsubmit = async (ev) => {
  ev.preventDefault();
  const imageOutput = document.querySelector('form#image+.output');
  const promptInput = document.querySelector('form#image input[name="prompt"]');
  imageOutput.textContent = 'Generating...';

  try {
    // Load the image as a base64 string
    const imageUrl = imageForm.elements.namedItem('chosen-image').value;
    const imageBase64 = await fetch(imageUrl)
      .then(r => r.arrayBuffer())
      .then(a => Base64.fromByteArray(new Uint8Array(a)));

    // Assemble the prompt by combining the text with the chosen image
    const contents = [
      {
        role: 'user',
        parts: [
          { inline_data: { mime_type: 'image/jpeg', data: imageBase64, } },
          { text: promptInput.value }
        ]
      }
    ];

    // Call the gemini-pro-vision model, and get a stream of results
    const result = await imageModel.generateContentStream({ contents });

    // Read from the stream and interpret the output as markdown
    const buffer = [];
    for await (const response of result.stream) {
      buffer.push(response.text());
      imageOutput.innerHTML = md.render(buffer.join(''));
    }
    chat.sendMessage("When asked more questions, continue talking about this recipe." + buffer.join(''))
    clearChatMessages()
  } catch (e) {
    imageOutput.innerHTML += '<hr>' + e;
  }
};

const chatForm = document.querySelector('form#chat');

chatForm.onsubmit = async (ev) => {
  ev.preventDefault();
  const chatInput = document.querySelector('form#chat input[name="chat"]');
  // Assemble the prompt by combining pre-determined text
  // "tell me a story" with what the user entered in the text field
  const message = chatInput.value;
  continueChatMessage(message, addChatMessage("end"))
  const p = addChatMessage("start");
  const buffer = [];
  try {
    const result = await chat.sendMessageStream(message);
    for await (const response of result.stream) {
      buffer.push(response.text());
      continueChatMessage(buffer.join(''), p)
    }
  }
  catch (e) {
    continueChatMessage(e.message, p);
  }
  chatInput.value = '';
};

// You can delete this once you've filled out an API key
maybeShowApiKeyBanner(GEN_API_KEY);

function addChatMessage(textAlign) {
  const chatHistory = document.querySelector('div.chat-history');
  const p = document.createElement('p')
  p.style.textAlign = textAlign
  p.textContent = "Waiting..."
  p.classList.add('output')
  chatHistory.appendChild(p)
  return p
}

function continueChatMessage(markdown, p) {
  p.innerHTML = md.render(markdown)
}

function clearChatMessages() {
  const chatHistory = document.querySelector('div.chat-history');
  while (chatHistory.hasChildNodes()) {
    chatHistory.removeChild(chatHistory.firstChild)
  }
}