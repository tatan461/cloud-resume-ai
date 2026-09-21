const COUNTER_API_URL = "https://uqn2o2aed8.execute-api.us-east-1.amazonaws.com/counter";
const CHAT_API_URL = "https://8lh865zm3i.execute-api.us-east-1.amazonaws.com/chat";

async function loadVisitCount() {
  const visitCount = document.getElementById("visit-count");

  try {
    const response = await fetch(COUNTER_API_URL, {
      method: "POST"
    });

    if (!response.ok) {
      throw new Error("Counter request failed");
    }

    const data = await response.json();
    visitCount.textContent = data.views ?? "N/A";
  } catch (error) {
    visitCount.textContent = "N/A";
  }
}

async function sendMessage() {
  const input = document.getElementById("chat-input");
  const chatWindow = document.getElementById("chat-window");
  const sendButton = document.getElementById("chat-send");
  const question = input.value.trim();

  if (!question || sendButton.disabled) {
    return;
  }

  chatWindow.insertAdjacentHTML(
    "beforeend",
    `<p class="chat-msg-user"><strong>You:</strong> ${escapeHtml(question)}</p>`
  );

  input.value = "";
  sendButton.disabled = true;
  sendButton.textContent = "Sending...";
  chatWindow.scrollTop = chatWindow.scrollHeight;

  try {
    const response = await fetch(CHAT_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ message: question })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "Something went wrong.");
    }

    chatWindow.insertAdjacentHTML(
      "beforeend",
      `<p class="chat-msg-bot"><strong>Assistant:</strong> ${escapeHtml(data.answer || "No answer returned.")}</p>`
    );
  } catch (error) {
    chatWindow.insertAdjacentHTML(
      "beforeend",
      `<p class="chat-msg-bot"><strong>Assistant:</strong> ${escapeHtml(error.message || "Network error, please try again.")}</p>`
    );
  } finally {
    sendButton.disabled = false;
    sendButton.textContent = "Send";
    chatWindow.scrollTop = chatWindow.scrollHeight;
    input.focus();
  }
}

function escapeHtml(value) {
  const div = document.createElement("div");
  div.textContent = String(value);
  return div.innerHTML;
}

document.addEventListener("DOMContentLoaded", () => {
  const sendButton = document.getElementById("chat-send");
  const input = document.getElementById("chat-input");

  sendButton.addEventListener("click", sendMessage);

  input.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault();
      sendMessage();
    }
  });

  loadVisitCount();
});
