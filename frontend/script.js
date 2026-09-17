const COUNTER_API_URL = "https://YOUR_API_GATEWAY_ENDPOINT/counter";
const CHAT_API_URL = "https://YOUR_API_GATEWAY_ENDPOINT/chat";

async function loadVisitCount() {
  try {
    const res = await fetch(COUNTER_API_URL, { method: "POST" });
    const data = await res.json();
    document.getElementById("visit-count").innerText = data.views;
  } catch (e) {
    document.getElementById("visit-count").innerText = "N/A";
  }
}

async function sendMessage() {
  const input = document.getElementById("chat-input");
  const chatWindow = document.getElementById("chat-window");
  const question = input.value.trim();
  if (!question) return;

  chatWindow.innerHTML += `<p><strong>You:</strong> ${question}</p>`;
  input.value = "";

  try {
    const res = await fetch(CHAT_API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question })
    });
    const data = await res.json();
    chatWindow.innerHTML += `<p><strong>Assistant:</strong> ${data.answer}</p>`;
  } catch (e) {
    chatWindow.innerHTML += `<p><strong>Assistant:</strong> Error while responding.</p>`;
  }
  chatWindow.scrollTop = chatWindow.scrollHeight;
}

document.getElementById("chat-send").addEventListener("click", sendMessage);
window.addEventListener("DOMContentLoaded", loadVisitCount);
