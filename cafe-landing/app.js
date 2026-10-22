const MENU = [
  {
    tag: "手冲",
    name: "云南·保山 日晒",
    desc: "莓果、红糖，酸质柔和，适合慢慢喝。",
    price: "¥32",
  },
  {
    tag: "手冲",
    name: "埃塞俄比亚 水洗",
    desc: "茉莉花香与柑橘，清爽明亮。",
    price: "¥36",
  },
  {
    tag: "意式",
    name: "澳白 Flat White",
    desc: "双份浓缩 + 丝绒奶沫，徐州冬天的标配。",
    price: "¥28",
  },
  {
    tag: "意式",
    name: "Dirty",
    desc: "冰牛奶打底，浓缩直接落杯。",
    price: "¥30",
  },
  {
    tag: "非咖",
    name: "陈皮煮梨茶",
    desc: "现煮，微甜，适合不喝咖啡的朋友。",
    price: "¥22",
  },
  {
    tag: "轻食",
    name: "酸面包牛油果塔",
    desc: "周末限定，配一勺番茄酱。",
    price: "¥38",
  },
];

function renderMenu() {
  const grid = document.getElementById("menuGrid");
  if (!grid) return;
  grid.innerHTML = MENU.map(
    (item) => `
    <article class="menu-card">
      <span class="tag">${item.tag}</span>
      <h3>${item.name}</h3>
      <p>${item.desc}</p>
      <div class="price">${item.price}</div>
    </article>`
  ).join("");
}

function setupNav() {
  const toggle = document.getElementById("navToggle");
  const nav = document.getElementById("nav");
  if (!toggle || !nav) return;

  toggle.addEventListener("click", () => {
    const open = nav.classList.toggle("open");
    toggle.setAttribute("aria-expanded", String(open));
  });

  nav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      nav.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
    });
  });
}

function setupHeader() {
  const header = document.querySelector(".site-header");
  if (!header) return;
  const onScroll = () => {
    header.classList.toggle("is-scrolled", window.scrollY > 8);
  };
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });
}

function setupForm() {
  const form = document.getElementById("contactForm");
  const hint = document.getElementById("formHint");
  if (!form || !hint) return;

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const data = new FormData(form);
    const name = data.get("name") || "朋友";
    const date = data.get("date") || "";
    const guests = data.get("guests") || "";
    hint.textContent = `已记录预约意向：${name} · ${date} · ${guests} 人（演示，未发送）`;
    hint.classList.add("ok");
    form.reset();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  renderMenu();
  setupNav();
  setupHeader();
  setupForm();
});
