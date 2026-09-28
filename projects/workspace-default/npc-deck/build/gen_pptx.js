const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13.33 × 7.5
pres.author = "ZCode";
pres.title = "智能NPC：目前游戏中落地最广的AI大模型应用";

// ===== 调色板（瑞士风 · IKB 克莱因蓝，全局唯一定义）=====
const BG = "FAFAF8", INK = "0A0A0A", ACCENT = "002FA7", BRIGHT = "5B7BFF";
const CARD = "F5F5F4", BORDER = "E0E0E0", T2 = "525252", T3 = "737373";
// 预混色（模拟透明度，避免 8 位 hex）
const ON_ACCENT_70 = "B2C0E4", ON_ACCENT_55 = "8CA1D7", ON_ACCENT_LINE = "4D6DC2";
const ON_INK_60 = "9D9D9D", ON_INK_50 = "848484", ON_INK_88 = "E1E1E1";
const F_ZH = "微软雅黑", F_EN = "Arial";

const W = 13.33, M = 0.5;
const s = pres.addSlide();
s.background = { color: BG };

// ===== 顶部 chrome =====
s.addText("AI × GAMES · LLM 应用落地评估", { x: M, y: 0.26, w: 5.5, h: 0.3, fontSize: 12, fontFace: F_ZH, color: T3, charSpacing: 2, margin: 0, valign: "middle" });
s.addText("SWISS · 26.09.28 · 01 / 01", { x: W - M - 4.5, y: 0.26, w: 4.5, h: 0.3, fontSize: 12, fontFace: F_ZH, color: T3, charSpacing: 2, align: "right", margin: 0, valign: "middle" });

// ===== 头部：kicker 在上、标题其下（左上对齐）=====
s.addText("SMART NPC · WHERE LLM LANDS IN GAMES", { x: M, y: 0.66, w: 8, h: 0.28, fontSize: 12, fontFace: F_EN, color: T3, charSpacing: 3, margin: 0, valign: "middle" });
s.addText("智能NPC", { x: M, y: 0.94, w: 2.75, h: 0.78, fontSize: 40, fontFace: F_ZH, color: INK, margin: 0, valign: "bottom", align: "left" });
s.addText("：目前游戏中落地最广的 AI 大模型应用", { x: 3.2, y: 1.36, w: 7.6, h: 0.36, fontSize: 18, fontFace: F_ZH, color: T2, margin: 0, valign: "bottom", align: "left" });
s.addText([
  { text: "目前 AI 在游戏领域", options: {} },
  { text: "落地最广、感知最强、也最成功", options: { bold: true, color: INK } },
  { text: "的应用方向。", options: {} },
], { x: M, y: 1.78, w: 10.5, h: 0.32, fontSize: 13, fontFace: F_ZH, color: T2, margin: 0, valign: "middle" });

// ===== 左 · 评估框架（ink 黑卡）=====
const IX = 0.5, IY = 2.28, IW = 3.5, IH = 4.72;
s.addShape(pres.shapes.RECTANGLE, { x: IX, y: IY, w: IW, h: IH, fill: { color: INK } });
s.addText("评估框架 · ROI", { x: IX + 0.28, y: IY + 0.24, w: 2.9, h: 0.28, fontSize: 12, fontFace: F_ZH, color: ON_INK_60, charSpacing: 2, margin: 0 });
s.addText("玩家体验", { x: IX + 0.28, y: IY + 1.02, w: 0.95, h: 0.4, fontSize: 16, fontFace: F_ZH, color: "FFFFFF", margin: 0, valign: "middle" });
s.addText("×", { x: IX + 1.23, y: IY + 1.02, w: 0.3, h: 0.4, fontSize: 16, fontFace: F_EN, color: BRIGHT, margin: 0, valign: "middle", align: "center" });
s.addText("商业价值", { x: IX + 1.53, y: IY + 1.02, w: 0.95, h: 0.4, fontSize: 16, fontFace: F_ZH, color: "FFFFFF", margin: 0, valign: "middle" });
s.addShape(pres.shapes.LINE, { x: IX + 0.28, y: IY + 1.62, w: 2.94, h: 0, line: { color: BRIGHT, width: 2.5 } });
s.addText("技术可行性", { x: IX + 0.28, y: IY + 1.8, w: 2.94, h: 0.4, fontSize: 16, fontFace: F_ZH, color: "FFFFFF", margin: 0, valign: "middle" });
s.addText("分子越高 · 分母越低 · 越值得做", { x: IX + 0.28, y: IY + 2.32, w: 2.94, h: 0.28, fontSize: 12, fontFace: F_ZH, color: ON_INK_50, margin: 0 });
s.addShape(pres.shapes.LINE, { x: IX + 0.28, y: IY + 3.5, w: 2.94, h: 0, line: { color: "3A3A3A", width: 0.75 } });
["技术上，行得通", "体验上，看得见", "商业上，有价值"].forEach((t, i) => {
  const ry = IY + 3.68 + i * 0.34;
  s.addShape(pres.shapes.RECTANGLE, { x: IX + 0.28, y: ry + 0.085, w: 0.09, h: 0.09, fill: { color: BRIGHT } });
  s.addText(t, { x: IX + 0.5, y: ry, w: 2.7, h: 0.28, fontSize: 13, fontFace: F_ZH, color: ON_INK_88, margin: 0, valign: "middle" });
});

// ===== 右 · 三方案卡 =====
const CX = 4.25, CW = W - M - 4.25, CH = 1.51, GAP = 0.195;
const plans = [
  {
    num: "01", title: "智能NPC", tag: "推荐主攻", accent: true,
    rows: [
      ["技术风险", "低", "模块化，容错高"],
      ["玩家感知", "极强", "直接、高频交互"],
      ["商业价值", "高", "营销亮点，提升留存"],
    ],
  },
  {
    num: "02", title: "AI 生成完整关卡 / 剧情", tag: "待验证", accent: false,
    rows: [
      ["技术风险", "高", "质量不可控，可能破坏核心体验"],
      ["玩家感知", "中等", "体验完才知道"],
      ["商业价值", "不确定", "可能是噱头"],
    ],
  },
  {
    num: "03", title: "AI 动态平衡经济", tag: "谨慎试水", accent: false,
    rows: [
      ["技术风险", "极高", "直接影响游戏公平性和寿命"],
      ["玩家感知", "弱", "大部分玩家无感"],
      ["商业价值", "高风险高回报", "需极度谨慎"],
    ],
  },
];

plans.forEach((p, pi) => {
  const CY = 2.28 + pi * (CH + GAP);
  const bg = p.accent ? ACCENT : CARD;
  const cTitle = p.accent ? "FFFFFF" : INK;
  const cTag = p.accent ? ON_ACCENT_55 : T3;
  const cNum = p.accent ? "FFFFFF" : T3;
  const cLabel = p.accent ? ON_ACCENT_70 : T3;
  const cNote = p.accent ? "FFFFFF" : T2;
  const cLine = p.accent ? ON_ACCENT_LINE : BORDER;

  s.addShape(pres.shapes.RECTANGLE, { x: CX, y: CY, w: CW, h: CH, fill: { color: bg } });
  s.addText(p.num, { x: CX + 0.2, y: CY, w: 0.9, h: CH, fontSize: 34, fontFace: F_EN, color: cNum, margin: 0, valign: "middle", charSpacing: 1 });
  s.addText(p.title, { x: CX + 1.15, y: CY + 0.1, w: 5.2, h: 0.32, fontSize: 16, fontFace: F_ZH, color: cTitle, bold: true, margin: 0, valign: "middle" });
  s.addText(p.tag, { x: CX + CW - 1.65, y: CY + 0.1, w: 1.4, h: 0.32, fontSize: 12, fontFace: F_ZH, color: cTag, align: "right", margin: 0, valign: "middle" });

  p.rows.forEach((r, ri) => {
    const ry = CY + 0.52 + ri * 0.33;
    s.addShape(pres.shapes.LINE, { x: CX + 1.15, y: ry, w: CW - 1.4, h: 0, line: { color: cLine, width: 0.5 } });
    s.addText(r[0], { x: CX + 1.15, y: ry + 0.02, w: 1.0, h: 0.3, fontSize: 12, fontFace: F_ZH, color: cLabel, margin: 0, valign: "middle" });
    s.addText(r[1], { x: CX + 2.25, y: ry + 0.02, w: 1.3, h: 0.3, fontSize: 13, fontFace: F_ZH, color: cTitle, bold: true, margin: 0, valign: "middle" });
    s.addText(r[2], { x: CX + 3.6, y: ry + 0.02, w: CW - 3.85, h: 0.3, fontSize: 12.5, fontFace: F_ZH, color: cNote, margin: 0, valign: "middle" });
  });
});

// ===== 演讲者备注 =====
s.addNotes(
  "先立框架：投入产出比 = 玩家体验 × 商业价值 ÷ 技术可行性。" +
  "智能NPC风险低、感知强、价值高，三项全占；" +
  "生成关卡质量不可控且感知滞后，动态经济直接碰公平性，只宜小步试水。" +
  "收在一句话：技术上行得通、体验上看得见、商业上有价值。"
);

pres.writeFile({ fileName: "../智能NPC-游戏AI落地评估.pptx" }).then(() => console.log("PPTX written"));
