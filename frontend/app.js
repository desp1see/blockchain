const contractAddress = "0x0B2eA28845226a45436A0591F14488dEfb7a1ef2";

const abi = [
  "constructor(string _greeting)",
  "function greeting() public view returns (string)",
  "function getGreeting() public view returns (string)",
  "function setGreeting(string _greeting) public"
];

function createParticle() {
  const particlesContainer = document.getElementById("particles");
  const particle = document.createElement("div");
  particle.classList.add("particle");

  const emojis = ["💀", "💖", "💝", "✨", "🖤", "🌸", "⭐", "🌟", "🕷️", "🕸️"];
  particle.textContent = emojis[Math.floor(Math.random() * emojis.length)];

  particle.style.left = Math.random() * 100 + "vw";

  const size = 25 + Math.random() * 35;
  particle.style.fontSize = size + "px";

  const duration = 10 + Math.random() * 8;
  particle.style.animationDuration = duration + "s";

  const direction = Math.random() > 0.5 ? "float" : "floatReverse";
  particle.style.animationName = direction;

  particle.style.animationDelay = Math.random() * 1.5 + "s";

  particlesContainer.appendChild(particle);

  setTimeout(() => {
    if (particle.parentElement) particle.remove();
  }, (duration + 2) * 1000);
}

setInterval(createParticle, 300);

document.addEventListener("DOMContentLoaded", () => {
  for (let i = 0; i < 25; i++) {
    setTimeout(createParticle, i * 100);
  }

  const connectBtn = document.getElementById("connectBtn");
  const setBtn = document.getElementById("setBtn");
  const refreshBtn = document.getElementById("refreshBtn");
  const greetingEl = document.getElementById("greeting");
  const newGreetingInput = document.getElementById("newGreeting");

  let provider, signer, contract;

  connectBtn.onclick = async () => {
    if (!window.ethereum) {
      alert("Установите MetaMask!");
      return;
    }

    try {
      provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      signer = await provider.getSigner();
      contract = new ethers.Contract(contractAddress, abi, signer);

      const address = await signer.getAddress();
      connectBtn.textContent = `Подключено: ${address.slice(0, 6)}...${address.slice(-4)}`;
      connectBtn.disabled = true;

      loadGreeting();
    } catch (error) {
      console.error(error);
      alert("Ошибка: " + error.message);
    }
  };

  async function loadGreeting() {
    if (!contract) {
      greetingEl.textContent = "Подключите кошелёк";
      return;
    }

    try {
      const current = await contract.getGreeting();
      greetingEl.textContent = current || "Hello, World!";
    } catch (error) {
      greetingEl.textContent = "Ошибка загрузки";
      console.error(error);
    }
  }

  setBtn.onclick = async () => {
    if (!contract) return alert("Подключите MetaMask!");

    const newText = newGreetingInput.value.trim();
    if (!newText) return alert("Введите текст!");

    try {
      setBtn.textContent = "Отправляем...";
      setBtn.disabled = true;
      const tx = await contract.setGreeting(newText);
      await tx.wait();
      loadGreeting();
      newGreetingInput.value = "";
      alert("Приветствие изменено! 💀💖");
    } catch (error) {
      console.error(error);
      alert("Ошибка: " + error.message);
    } finally {
      setBtn.textContent = "Изменить";
      setBtn.disabled = false;
    }
  };

  refreshBtn.onclick = loadGreeting;

  if (window.ethereum?.selectedAddress) {
    connectBtn.click();
  }
});