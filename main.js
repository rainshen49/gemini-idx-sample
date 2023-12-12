import { GoogleGenerativeAI } from "@google/generative-ai";
import './style.css';

let GEN_API_KEY = import.meta.env.VITE_GEN_AI_KEY;

let form = document.querySelector('form');
let input = document.querySelector('input[name="prompt"]');
let output = document.querySelector('.output');

form.onsubmit = async (ev) => {
  ev.preventDefault();
  output.textContent = 'Generating...';
  // Assemble the prompt by combining pre-determined text
  // "tell me a story" with what the user entered in the text field
  let subject = input.value;
  let prompt = `Tell me a very short story about: ${subject}`;

  const genAI = new GoogleGenerativeAI(GEN_API_KEY);
  const model = genAI.getGenerativeModel({
    model: "gemini-pro",
  });
  try {

    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
    });
    const response = result.response;
    output.textContent = response.candidates[0].content.parts[0].text;
    console.log(response);
    input.setAttribute('placeholder', subject);
    input.value = '';
  }
  catch (e) {
    input.setAttribute('placeholder', subject);
    input.value = '';
    output.textContent = e.message;
  }
};