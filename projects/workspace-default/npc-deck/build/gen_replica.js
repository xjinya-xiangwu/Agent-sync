const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13.333 × 7.5 in,原图 1999×1124 ≈ 16:9,1px ≈ 1/150 in
pres.author = "ZCode";
pres.title = "智能NPC：目前游戏中落地最广的AI大模型应用";

// ===== 原图取色 =====
const BLUE = "252FA4";    // 深蓝横幅/标签框/强调文字(原图采样 RGB 37,47,164)
const YELLOW = "F2B70A";  // 金黄表头/公式框
const GOLD_LINE = "F4CA41"; // 分式横线(原图采样 RGB 244,202,65)
const LAV = "DFE3F3";     // 数据格浅紫灰底
const GREEN = "27A45D";   // 低
const RED = "D6403C";     // 极强/高
const GREY = "8F8F8F";    // 注释灰
const BLACK = "1A1A1A";
const F = "微软雅黑";

const s = pres.addSlide();
s.background = { color: "FFFFFF" };

// ===== 顶部深蓝横幅 + 白色粗斜体标题 =====
s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 13.333, h: 0.70, fill: { color: BLUE } });
s.addText("智能NPC：目前游戏中落地最广的AI大模型应用", {
  x: 0.15, y: 0.03, w: 12.2, h: 0.64, fontSize: 30, fontFace: F, color: "FFFFFF",
  bold: true, italic: true, margin: 0, valign: "middle", align: "left",
});

// ===== 左上导语(黑色加粗) =====
s.addText("目前AI在游戏领域落地最广、感知最强、也最成功的应用。", {
  x: 0.5, y: 1.28, w: 6.4, h: 0.34, fontSize: 16, fontFace: F, color: BLACK,
  bold: true, margin: 0, valign: "middle",
});

// ===== 投入产出比? + 右上分式公式 =====
s.addText("投入产出比?", {
  x: 7.12, y: 1.24, w: 2.15, h: 0.42, fontSize: 20, fontFace: F, color: BLUE,
  bold: true, italic: true, margin: 0, valign: "middle",
});
// 分子:玩家体验 × 商业价值(黄底白字,× 为金色,中缝收窄)
s.addShape(pres.shapes.RECTANGLE, { x: 9.33, y: 0.98, w: 1.33, h: 0.32, fill: { color: YELLOW } });
s.addText("玩家体验", { x: 9.33, y: 0.98, w: 1.33, h: 0.32, fontSize: 13, fontFace: F, color: "FFFFFF", bold: true, align: "center", valign: "middle", margin: 0 });
s.addText("×", { x: 10.66, y: 0.98, w: 0.26, h: 0.32, fontSize: 15, fontFace: F, color: YELLOW, bold: true, align: "center", valign: "middle", margin: 0 });
s.addShape(pres.shapes.RECTANGLE, { x: 10.92, y: 0.98, w: 1.32, h: 0.32, fill: { color: YELLOW } });
s.addText("商业价值", { x: 10.92, y: 0.98, w: 1.32, h: 0.32, fontSize: 13, fontFace: F, color: "FFFFFF", bold: true, align: "center", valign: "middle", margin: 0 });
// 分式横线(金黄,加粗)
s.addShape(pres.shapes.LINE, { x: 9.3, y: 1.38, w: 3.05, h: 0, line: { color: GOLD_LINE, width: 2.5 } });
// 分母:技术可行性
s.addShape(pres.shapes.RECTANGLE, { x: 10.05, y: 1.48, w: 1.45, h: 0.32, fill: { color: YELLOW } });
s.addText("技术可行性", { x: 10.05, y: 1.48, w: 1.45, h: 0.32, fontSize: 13, fontFace: F, color: "FFFFFF", bold: true, align: "center", valign: "middle", margin: 0 });

// ===== 主表(像素坐标 ÷150 换算) =====
// 列:标签 1.547/w1.44 · col1 3.033/w2.41 · col2 5.467/w2.92 · col3 8.413/w2.72
const COLS = [
  { x: 1.547, w: 1.44 },
  { x: 3.033, w: 2.41 },
  { x: 5.467, w: 2.92 },
  { x: 8.413, w: 2.92 },
];
const HEADERS = ["智能NPC", "AI生成完整关卡/剧情", "AI动态平衡经济"];
const ROWS = [
  { y: 2.32, h: 0.71, label: "应用" },
  { y: 3.37, h: 0.70, label: "技术风险" },
  { y: 4.39, h: 0.70, label: "玩家感知" },
  { y: 5.43, h: 0.70, label: "商业价值" },
];
// 数据:每格 [值, 值颜色, 注释]
const DATA = [
  null,
  { cells: [["低", GREEN, "模块化，容错高"], ["高", BLACK, "质量不可控，可能破坏核心体验"], ["极高", BLACK, "直接影响游戏公平性和寿命"]] },
  { cells: [["极强", RED, "直接、高频交互"], ["中等", BLACK, "体验完才知道"], ["弱", BLACK, "大部分玩家无感"]] },
  { cells: [["高", RED, "营销亮点，提升留存"], ["不确定", BLACK, "可能是噱头"], ["高风险高回报", BLACK, "需极度谨慎"]] },
];

ROWS.forEach((row, ri) => {
  // 第 0 列:深蓝标签框,白色加粗居中
  s.addShape(pres.shapes.RECTANGLE, { x: COLS[0].x, y: row.y, w: COLS[0].w, h: row.h, fill: { color: BLUE } });
  s.addText(row.label, { x: COLS[0].x, y: row.y, w: COLS[0].w, h: row.h, fontSize: 16, fontFace: F, color: "FFFFFF", bold: true, align: "center", valign: "middle", margin: 0 });

  // 第 1-3 列
  for (let ci = 1; ci <= 3; ci++) {
    const c = COLS[ci];
    if (ri === 0) {
      // 表头行:金黄底,深蓝粗斜体
      s.addShape(pres.shapes.RECTANGLE, { x: c.x, y: row.y, w: c.w, h: row.h, fill: { color: YELLOW } });
      s.addText(HEADERS[ci - 1], { x: c.x, y: row.y, w: c.w, h: row.h, fontSize: 19, fontFace: F, color: BLUE, bold: true, italic: true, align: "center", valign: "middle", margin: 0 });
    } else {
      // 数据行:浅紫灰底,值 + 灰色斜体注释
      s.addShape(pres.shapes.RECTANGLE, { x: c.x, y: row.y, w: c.w, h: row.h, fill: { color: LAV } });
      const [val, color, note] = DATA[ri].cells[ci - 1];
      s.addText(val, { x: c.x, y: row.y + 0.09, w: c.w, h: 0.3, fontSize: 16, fontFace: F, color, bold: true, italic: true, align: "center", valign: "middle", margin: 0 });
      s.addText(note, { x: c.x + 0.06, y: row.y + 0.4, w: c.w - 0.12, h: 0.24, fontSize: 11.5, fontFace: F, color: GREY, italic: true, align: "center", valign: "middle", margin: 0 });
    }
  }
});

// ===== 底部结论(蓝色粗斜体,居中) =====
s.addText("技术上行得通、体验上看得见、商业上有价值", {
  x: 0, y: 6.6, w: 13.333, h: 0.4, fontSize: 16, fontFace: F, color: BLUE,
  bold: true, italic: true, align: "center", valign: "middle", margin: 0,
});

s.addNotes("复刻页:智能NPC vs 生成关卡/剧情 vs 动态平衡经济,三维对比(技术风险/玩家感知/商业价值);结论:技术上行得通、体验上看得见、商业上有价值。");

pres.writeFile({ fileName: "../智能NPC-游戏AI落地评估.pptx" }).then(() => console.log("PPTX written"));
