const CONTRACT_ADDRESS = "0xE834D60bb38cB20aCCD7D7B88972929a0994D42e";

const ABI = [
  "function owner() view returns (address)",
  "function getBalance() view returns (uint)",
  "function sendETH(address payable _to, uint _amount)",
  "event Received(address indexed from, uint amount)",
  "event Sent(address indexed to, uint amount)"
];

let provider, signer, contract, userAddress;

document.addEventListener("DOMContentLoaded", () => {
  const connectBtn = document.getElementById("connectBtn");
  const depositBtn = document.getElementById("depositBtn");
  const withdrawBtn = document.getElementById("withdrawBtn");
  const balanceEl = document.getElementById("balance");
  const ownerEl = document.getElementById("owner");
  const eventsList = document.getElementById("eventsList");

  connectBtn.onclick = async () => {
    if (!window.ethereum) return alert("Установите MetaMask!");
    try {
      provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      signer = await provider.getSigner();
      userAddress = await signer.getAddress();
      contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      connectBtn.innerText = `Подключено: ${userAddress.slice(0,6)}...${userAddress.slice(-4)}`;
      loadData();
      setupEventListeners();
    } catch (err) {
      alert("Ошибка: " + err.message);
    }
  };

  async function loadData() {
    const owner = await contract.owner();
    const balance = await contract.getBalance();
    ownerEl.textContent = owner;
    balanceEl.textContent = ethers.formatEther(balance);
  }

  function logEvent(text) {
    const li = document.createElement("li");
    li.textContent = `[${new Date().toLocaleTimeString()}] ${text}`;
    eventsList.prepend(li);
  }

  function setupEventListeners() {
    contract.on("Received", (from, amount) => {
      logEvent(`Получено ${ethers.formatEther(amount)} ETH от ${from}`);
      loadData();
    });

    contract.on("Sent", (to, amount) => {
      logEvent(`Отправлено ${ethers.formatEther(amount)} ETH на ${to}`);
      loadData();
    });
  }

  depositBtn.onclick = async () => {
    const amount = document.getElementById("depositAmount").value;
    if (!amount || amount <= 0) return alert("Введите сумму");
    try {
      const tx = await signer.sendTransaction({
        to: CONTRACT_ADDRESS,
        value: ethers.parseEther(amount)
      });
      logEvent(`Пополнение на ${amount} ETH...`);
      await tx.wait();
      logEvent(`Пополнено ${amount} ETH`);
    } catch (err) {
      alert("Ошибка: " + err.message);
    }
  };

  withdrawBtn.onclick = async () => {
    const to = document.getElementById("withdrawTo").value;
    const amount = document.getElementById("withdrawAmount").value;
    if (!ethers.isAddress(to)) return alert("Неверный адрес");
    if (!amount || amount <= 0) return alert("Введите сумму");
    try {
      const tx = await contract.sendETH(to, ethers.parseEther(amount));
      logEvent(`Вывод ${amount} ETH на ${to}...`);
      await tx.wait();
      logEvent(`Успешно выведено ${amount} ETH`);
    } catch (err) {
      alert("Ошибка (только владелец): " + err.message);
    }
  };
});