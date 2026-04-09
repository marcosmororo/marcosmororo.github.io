
(function () {
  const tema = localStorage.getItem("tema");
  if (tema === "light") document.body.classList.add("light");
})();

function toggleTheme() {
  document.body.classList.toggle("light");
  localStorage.setItem("tema",
    document.body.classList.contains("light") ? "light" : "dark"
  );
  atualizarBotao();
}

function atualizarBotao() {
  const btn = document.querySelector(".theme-btn");
  if (btn) btn.textContent =
    document.body.classList.contains("light") ? "🌙" : "☀️";
}

window.onload = atualizarBotao;

let tempo = localStorage.getItem("tempo")
  ? parseInt(localStorage.getItem("tempo")) : 1500;

let rodando = localStorage.getItem("rodando") === "true";
let intervalo;

function atualizarTempo() {
  const el = document.getElementById("tempo");
  if (!el) return;
  let m = Math.floor(tempo/60);
  let s = tempo%60;
  el.innerText = `${String(m).padStart(2,"0")}:${String(s).padStart(2,"0")}`;
}

function salvar() {
  localStorage.setItem("tempo", tempo);
  localStorage.setItem("rodando", rodando);
}

function iniciar() {
  if (!intervalo) {
    rodando = true;
    intervalo = setInterval(()=>{
      if (tempo>0){ tempo--; atualizarTempo(); salvar(); }
    },1000);
  }
}

function pausar() {
  clearInterval(intervalo);
  intervalo=null;
  rodando=false;
  salvar();
}

function resetar() {
  pausar();
  tempo=1500;
  atualizarTempo();
  salvar();
}

if (rodando) iniciar();
setInterval(atualizarTempo,500);
