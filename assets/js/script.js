// =====================
// TEMA (GLOBAL)
// =====================
document.addEventListener("DOMContentLoaded", () => {
  const tema = localStorage.getItem("tema");

  if (tema === "light") {
    document.body.classList.add("light");
  }

  atualizarBotao();
  atualizarTempo();
  renderizar();

  if (rodando) iniciar();
});

function toggleTheme() {
  document.body.classList.toggle("light");

  const isLight = document.body.classList.contains("light");
  localStorage.setItem("tema", isLight ? "light" : "dark");

  atualizarBotao();
}

function atualizarBotao() {
  const btn = document.querySelector(".theme-btn");
  if (btn) {
    btn.textContent =
      document.body.classList.contains("light") ? "🌙" : "☀️";
  }
}

// =====================
// TIMER
// =====================
let tempo = localStorage.getItem("tempo")
  ? parseInt(localStorage.getItem("tempo")) : 1500;

let rodando = localStorage.getItem("rodando") === "true";
let intervalo = null;

function atualizarTempo() {
  const el = document.getElementById("tempo");
  if (!el) return;

  let m = Math.floor(tempo / 60);
  let s = tempo % 60;

  el.innerText = `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

function salvarTempo() {
  localStorage.setItem("tempo", tempo);
  localStorage.setItem("rodando", rodando);
}

function iniciar() {
  if (!intervalo) {
    rodando = true;

    intervalo = setInterval(() => {
      if (tempo > 0) {
        tempo--;
        atualizarTempo();
        salvarTempo();
      }
    }, 1000);
  }
}

function pausar() {
  clearInterval(intervalo);
  intervalo = null;
  rodando = false;
  salvarTempo();
}

function resetar() {
  pausar();
  tempo = 1500;
  atualizarTempo();
  salvarTempo();
}

// =====================
// ZABBIX TREE
// =====================
let estrutura = JSON.parse(localStorage.getItem("estruturaZabbix")) || [
  {
    nome: "Core",
    filhos: [
      {
        nome: "Vendors",
        filhos: [
          { nome: "Juniper", filhos: [] },
          { nome: "Huawei", filhos: [] }
        ]
      }
    ]
  },
  {
    nome: "Distribution",
    filhos: [
      {
        nome: "Vendors",
        filhos: [
          { nome: "Juniper", filhos: [] },
          { nome: "Huawei", filhos: [] },
          { nome: "ZTE", filhos: [] }
        ]
      }
    ]
  }
];

let itemSelecionado = null;

function salvarEstrutura() {
  localStorage.setItem("estruturaZabbix", JSON.stringify(estrutura));
}

function renderizar() {
  const ul = document.getElementById("arvore");
  if (!ul) return;

  ul.innerHTML = "";
  estrutura.forEach(item => ul.appendChild(criarElemento(item)));
}

function criarElemento(item) {
  const li = document.createElement("li");

  const span = document.createElement("span");
  span.textContent = item.nome;
  span.style.cursor = "pointer";

  span.onclick = () => {
    itemSelecionado = item;

    document.querySelectorAll("#arvore span")
      .forEach(s => s.style.fontWeight = "normal");

    span.style.fontWeight = "bold";
  };

  li.appendChild(span);

  const btnRemover = document.createElement("button");
  btnRemover.textContent = "❌";
  btnRemover.style.marginLeft = "10px";

  btnRemover.onclick = () => {
    removerItem(estrutura, item);
    salvarEstrutura();
    renderizar();
  };

  li.appendChild(btnRemover);

  if (item.filhos.length > 0) {
    const ul = document.createElement("ul");
    item.filhos.forEach(f => ul.appendChild(criarElemento(f)));
    li.appendChild(ul);
  }

  return li;
}

function adicionarItem() {
  const input = document.getElementById("novoItem");
  if (!input) return;

  const nome = input.value.trim();
  if (!nome) return;

  const novo = { nome, filhos: [] };

  if (itemSelecionado) {
    itemSelecionado.filhos.push(novo);
  } else {
    estrutura.push(novo);
  }

  input.value = "";
  salvarEstrutura();
  renderizar();
}

function removerItem(lista, item) {
  const index = lista.indexOf(item);

  if (index !== -1) {
    lista.splice(index, 1);
    return true;
  }

  for (let i of lista) {
    if (removerItem(i.filhos, item)) return true;
  }

  return false;
}
