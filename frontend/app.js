const contractAddress = "0x0B2eA28845226a45436A0591F14488dEfb7a1ef2";

const abi = [
  "constructor(string _greeting)",
  "function greeting() public view returns (string)",
  "function getGreeting() public view returns (string)",
  "function setGreeting(string _greeting) public"
];

// Генерация летающих частиц 💀💖
function createParticle() {
  const particlesContainer = document.getElementById("particles");
  const particle = document.createElement("div");
  particle.classList.add("particle");
  
  // Рандомно череп или сердце
  particle.textContent = Math.random() > 0.5 ? "💀" : "💖";
  
  // Рандомная позиция по горизонтали
  particle.style.left = Math.random() * 100 + "vw";
  
  // Рандомная задержка и длительность анимации
  particle.style.animationDuration = 10 + Math.random() * 10 + "s";
  particle.style.animationDelay = Math.random() * 5 + "s";
  
  particlesContainer.appendChild(particle);
  
  // Удаляем через 25 секунд, чтобы не засорять DOM
  setTimeout(() => {
    particle.remove();
  }, 25000);
}

// Создаём новые частицы каждые 800 мс
setInterval(createParticle, 800);

// Основная логика dApp
document.addEventListener("DOMContentLoaded", () => {
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

  // Автоподключение, если уже авторизованы
  if (window.ethereum?.selectedAddress) {
    connectBtn.click();
  }
});