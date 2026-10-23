// Thin, fixed client: renders what the server sends and posts answers back. It holds no answer
// keys and makes no learning decisions; every question, score and reveal comes from /api/*.
"use strict";

const TEXT = "︎"; // force text (not emoji) presentation of chess glyphs on iOS
const GLYPH = { wk: "♚" + TEXT, bk: "♚" + TEXT, p: "♟" + TEXT };
const FILES = "abcdefgh";

const main = document.getElementById("main");
const progress = document.getElementById("progress");
const footer = document.getElementById("footer");
const state = { item: null, answered: 0, correct: 0, scored: 0, recorded: 0 };

function el(tag, attrs = {}, children = []) {
	const node = document.createElement(tag);
	for (const [k, v] of Object.entries(attrs)) {
		if (k === "text") node.textContent = v;
		else if (k === "class") node.className = v;
		else if (k.startsWith("on")) node.addEventListener(k.slice(2), v);
		else node.setAttribute(k, v);
	}
	for (const c of children) if (c) node.append(c);
	return node;
}

async function api(path, body = {}) {
	const res = await fetch(path, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
	const data = await res.json().catch(() => ({ error: "bad response" }));
	if (!res.ok) throw new Error(data.error || res.status);
	return data;
}

function show(...nodes) {
	main.replaceChildren(...nodes);
	window.scrollTo(0, 0);
}

function fail(err) {
	show(el("div", { class: "card" }, [
		el("h2", { text: "Something went wrong" }),
		el("p", { class: "lead", text: String(err.message || err) }),
		el("button", { class: "primary", text: "Back to lessons", onclick: showLessons }),
	]));
}

// Board: pieces from {wk, bk, p, stm}; interactive when legal moves are given.
function renderBoard(board, opts = {}) {
	const grid = el("div", { class: "board", role: "grid", "aria-label": "chess board" });
	const pieceAt = {};
	if (board.wk) pieceAt[board.wk] = ["wk", "piece-white", "White king"];
	if (board.p) pieceAt[board.p] = ["p", "piece-white", "White pawn"];
	if (board.bk) pieceAt[board.bk] = ["bk", "piece-black", "Black king"];
	const cells = {};
	for (let r = 8; r >= 1; r--) {
		grid.append(el("div", { class: "coord", text: String(r) }));
		for (let f = 0; f < 8; f++) {
			const name = FILES[f] + r;
			const piece = pieceAt[name];
			const cell = el("button", {
				type: "button",
				class: "sq" + ((f + r) % 2 === 1 ? " dark" : ""),
				"aria-label": name + (piece ? " " + piece[2] : ""),
				"data-sq": name,
			});
			if (piece) cell.append(el("span", { class: piece[1], text: GLYPH[piece[0]] }));
			cells[name] = cell;
			grid.append(cell);
		}
	}
	grid.append(el("div"));
	for (const f of FILES) grid.append(el("div", { class: "coord", text: f }));

	if (opts.legal) {
		const byFrom = {};
		for (const m of opts.legal) (byFrom[m.slice(0, 2)] ||= []).push(m.slice(2, 4));
		let selected = null;
		const clear = () => Object.values(cells).forEach((c) => c.classList.remove("selected", "target"));
		const select = (from) => {
			clear();
			selected = from;
			cells[from].classList.add("selected");
			for (const to of byFrom[from]) cells[to].classList.add("target");
		};
		const froms = Object.keys(byFrom);
		if (froms.length === 1) select(froms[0]);
		grid.addEventListener("click", (ev) => {
			const sq = ev.target.closest(".sq")?.dataset.sq;
			if (!sq || opts.locked()) return;
			if (byFrom[sq]) return select(sq);
			if (selected && byFrom[selected].includes(sq)) {
				clear();
				opts.onMove(selected + sq);
			}
		});
	}
	return { node: el("div", { class: "board-wrap" }, [grid]), cells };
}

function toMove(board) {
	if (!board.stm) return null;
	return el("p", { class: "to-move", text: (board.stm === "white" ? "White" : "Black") + " to move" });
}

async function showLessons() {
	footer.hidden = true;
	progress.textContent = "";
	try {
		const { lessons, in_progress } = await api("/api/lessons");
		const list = el("div", { class: "lessons" });
		for (const l of lessons) {
			const generated = l.id === "review" || l.id === "checkpoint";
			const badge = generated ? el("span", { class: "badge" + (l.due ? "" : " done"), text: l.due ? "Due" : "Clear" })
				: l.completed ? el("span", { class: "badge done", text: "Done" })
				: l.unlocked ? el("span", { class: "badge", text: "Open" })
				: el("span", { class: "badge", text: "Day " + (l.day + 1) });
			const resuming = l.id === in_progress;
			const isReview = l.id === "review";
			const button = el("button", { class: "lesson", type: "button", onclick: () => (resuming ? resumeLesson() : startLesson(l.id)) }, [
				el("span", {}, [el("div", { class: "title", text: l.title }),
					el("div", { class: "meta", text: resuming ? "In progress: tap to resume"
						: isReview ? (l.due ? `${l.due} idea${l.due === 1 ? "" : "s"} due for review, with fresh positions` : "Nothing due right now")
						: l.id === "checkpoint" ? (l.due ? "A short unmarked check of what you remember" : "Nothing due right now")
						: l.unlocked ? (l.completed ? "Practice again any time" : "Ready") : "Unlocks on day " + (l.day + 1) })]),
				badge,
			]);
			if (!l.unlocked) button.disabled = true;
			list.append(button);
		}
		show(
			el("h1", { text: "King and pawn endgames" }),
			el("p", { class: "lead", text: "One short lesson a day, then a check a week later. Lessons unlock by calendar day, because spacing them out is what makes them stick." }),
			list,
		);
	} catch (err) { fail(err); }
}

async function resumeLesson() {
	footer.hidden = false;
	await nextItem();
}

async function startLesson(id) {
	try {
		await api("/api/start", { lesson_id: id });
		Object.assign(state, { answered: 0, correct: 0, scored: 0, recorded: 0 });
		footer.hidden = false;
		await nextItem();
	} catch (err) { fail(err); }
}

async function nextItem() {
	try {
		const res = await api("/api/next");
		if (res.done) return showDone();
		state.item = res.item;
		state.progress = res.progress;
		renderItem(res.item);
	} catch (err) { fail(err); }
}

function progressText() {
	const p = state.progress;
	const where = p ? `${p.position} of ${p.total}` : "";
	return state.scored ? `${where} · ${state.correct}/${state.scored} correct` : where;
}

function renderItem(item) {
	progress.textContent = progressText();
	const card = el("div", { class: "card" });
	const board = item.prompt.board;
	let locked = false;
	const kind = item.response.kind;
	card.append(el("p", { class: "prompt", text: item.prompt.text }));
	let rendered = null;
	if (board) {
		rendered = renderBoard(board, kind === "move" ? {
			legal: item.response.legal_moves,
			locked: () => locked,
			onMove: (move) => { locked = true; submit({ move }, "tap", rendered, card); },
		} : {});
		card.append(rendered.node);
		const note = toMove(board);
		if (note) card.append(note);
	}
	if (kind === "info") {
		card.append(el("button", { class: "primary", text: "Continue", onclick: async () => {
			await api("/api/submit", { item_id: item.id, answer: { ack: true }, modality: "tap", hint_level: 0 });
			nextItem();
		} }));
	} else if (kind === "choice") {
		const choices = el("div", { class: "choices" + (item.response.choices.length === 2 ? " two" : "") });
		for (const c of item.response.choices) {
			choices.append(el("button", { class: "choice", type: "button", text: c.label, "data-id": c.id, onclick: () => {
				if (locked) return;
				locked = true;
				submit({ choice: c.id }, "tap", rendered, card);
			} }));
		}
		card.append(choices);
	} else if (kind === "move") {
		card.append(el("p", { class: "hint", text: "Tap a piece, then tap where it should go." }));
	} else if (kind === "typed") {
		const input = el("input", { type: "text", autocomplete: "off", "aria-label": "answer" });
		card.append(el("form", { onsubmit: (ev) => { ev.preventDefault(); if (!locked) { locked = true; submit({ text: input.value }, "type", rendered, card); } } },
			[input, el("button", { class: "primary", text: "Answer" })]));
	}
	show(card);
}

async function submit(answer, modality, rendered, card) {
	try {
		const res = await api("/api/submit", { item_id: state.item.id, answer, modality, hint_level: 0 });
		if (res.recorded) return showRecorded(card);
		state.scored += 1;
		if (res.correct) state.correct += 1;
		showFeedback(res, answer, rendered, card);
	} catch (err) { fail(err); }
}

function showFeedback(res, answer, rendered, card) {
	state.answeredCard = card;
	const reveal = res.reveal || {};
	for (const b of card.querySelectorAll("button.choice")) {
		if (b.dataset.id === reveal.choice) b.classList.add("correct");
		else if (b.dataset.id === answer.choice) b.classList.add("incorrect");
	}
	if (answer.move && rendered) {
		for (const m of reveal.accepted || []) rendered.cells[m.slice(2, 4)].classList.add("answer");
		if (!res.correct) rendered.cells[answer.move.slice(2, 4)].classList.add("wrong");
	}
	let heading = res.correct ? "Correct." : "Not quite.";
	if (!res.correct && answer.move && reveal.accepted) {
		heading += " Winning move" + (reveal.accepted.length > 1 ? "s: " : ": ") + reveal.accepted.map((m) => (m.slice(0, 2) === state.item.prompt.board.wk ? "K" : "") + m.slice(2, 4)).join(", ");
	}
	card.append(el("div", { class: "feedback " + (res.correct ? "good" : "bad") }, [
		el("strong", { text: heading }),
		reveal.refutation ? el("p", { text: reveal.refutation }) : null,
		reveal.feedback ? el("span", { text: reveal.feedback }) : null,
	]));
	card.append(el("button", { class: "primary", text: "Next", onclick: nextItem }));
	progress.textContent = progressText();
}

// Checkpoint answers are recorded without marking, so nothing about correctness is shown.
function showRecorded(card) {
	state.recorded += 1;
	state.answeredCard = null;
	card.append(el("div", { class: "feedback neutral" }, [el("strong", { text: "Recorded." })]));
	card.append(el("button", { class: "primary", text: "Next", onclick: nextItem }));
	progress.textContent = progressText();
}

function showDone() {
	footer.hidden = true;
	if (state.recorded && !state.scored) {
		return show(el("div", { class: "card" }, [
			el("h2", { text: "Checkpoint recorded" }),
			el("p", { class: "lead", text: `${state.recorded} answer${state.recorded === 1 ? "" : "s"} recorded. Checkpoints are not marked here; they measure what stays with you over time.` }),
			el("button", { class: "primary", text: "Back to lessons", onclick: showLessons }),
		]));
	}
	show(el("div", { class: "card" }, [
		el("h2", { text: "Lesson complete" }),
		el("div", { class: "summary", text: `${state.correct} / ${state.scored}` }),
		el("p", { class: "lead", text: "Come back tomorrow for the next lesson. The one-week check will mix everything, including one position type you haven't seen." }),
		el("button", { class: "primary", text: "Back to lessons", onclick: showLessons }),
	]));
}

// "I think you're wrong" / "This isn't working right": never counted against the learner.
const REPORTS = {
	challenge: { title: "What do you think is wrong?", kinds: [["wrong", "The answer or explanation is wrong"]] },
	broken: { title: "What isn't working?", kinds: [["broken", "Something is broken"], ["confusing", "I don't know what to do"], ["too_hard", "This is too hard"], ["too_easy", "This is too easy"], ["other", "Something else"]] },
};

function openReport(which) {
	const spec = REPORTS[which];
	const dialog = document.getElementById("report");
	document.getElementById("report-title").textContent = spec.title;
	const kinds = document.getElementById("report-kinds");
	let chosen = spec.kinds[0][0];
	kinds.replaceChildren(...spec.kinds.map(([id, label]) => el("button", { type: "button", class: id === chosen ? "on" : "", text: label, onclick: (ev) => {
		chosen = id;
		for (const b of kinds.children) b.classList.toggle("on", b === ev.currentTarget);
	} })));
	document.getElementById("report-note").value = "";
	dialog.onclose = async () => {
		if (dialog.returnValue !== "send") return;
		try {
			const res = await api("/api/report", { kind: chosen, item_id: state.item ? state.item.id : "", note: document.getElementById("report-note").value });
			if (res.settled) showRuling(res.settled);
			else progress.textContent = "Thanks, noted.";
		} catch (err) { fail(err); }
	};
	dialog.showModal();
}

// The oracle's ruling on a challenge, shown on the answered card. An upheld challenge also
// fixes the running tally, since the server has corrected the score.
function showRuling(ruling) {
	if (ruling.upheld) state.correct += ruling.correct ? 1 : -1;
	const heading = ruling.upheld
		? `You caught a grading error. Your answer is now scored ${ruling.correct ? "correct" : "incorrect"}.`
		: "Checked by the solver: the original score stands.";
	const box = el("div", { class: "feedback ruling " + (ruling.upheld ? "good" : "neutral") }, [
		el("strong", { text: heading }),
		el("p", { text: ruling.proof }),
	]);
	const card = state.answeredCard;
	const next = card && card.querySelector("button.primary:last-child");
	if (card && next) card.insertBefore(box, next); else if (card) card.append(box);
	progress.textContent = progressText();
}

document.getElementById("challenge").addEventListener("click", () => openReport("challenge"));
document.getElementById("broken").addEventListener("click", () => openReport("broken"));
document.getElementById("home").addEventListener("click", showLessons);
showLessons();
