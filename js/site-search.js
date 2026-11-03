/* Client-side search over Hugo's generated /index.json. No external service. */
(() => {
  "use strict";

  const app = document.querySelector("[data-site-search]");
  if (!app) return;

  const field = app.querySelector("[data-site-search-input]");
  const status = app.querySelector("[data-site-search-status]");
  const results = app.querySelector("[data-site-search-results]");
  const query = (new URLSearchParams(window.location.search).get("q") || "").trim();

  field.value = query;
  document.querySelectorAll("[data-header-search-input]").forEach((input) => {
    input.value = query;
  });

  if (!query) return;

  const normalise = (value) =>
    String(value || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();

  const terms = [...new Set(normalise(query).split(/\s+/).filter(Boolean))];
  if (!terms.length) return;

  const phrase = terms.join(" ");
  const excerpt = (entry) => {
    const full = String(entry.content || "").replace(/\s+/g, " ").trim();
    const short = String(entry.summary || "").replace(/\s+/g, " ").trim();
    const matching = (text) => terms.some((term) => normalise(text).includes(term));
    const text = matching(full) ? full : (short || full);

    if (text.length <= 220) return text;

    const lowered = normalise(text);
    const positions = terms.map((term) => lowered.indexOf(term)).filter((p) => p >= 0);
    const start = positions.length ? Math.max(0, Math.min(...positions) - 70) : 0;
    const fragment = text.slice(start, start + 220).trim();
    return (start > 0 ? "…" : "") + fragment + (start + 220 < text.length ? "…" : "");
  };

  const scoreEntry = (entry) => {
    const title = normalise(entry.title);
    const section = normalise(entry.section);
    const summary = normalise(entry.summary);
    const body = normalise(entry.content);

    // All words must occur somewhere in the page, in any order.
    if (!terms.every((term) => (title + " " + section + " " + summary + " " + body).includes(term))) {
      return 0;
    }

    let score = title.includes(phrase) ? 80 : 0;
    for (const term of terms) {
      if (title.includes(term)) score += 30;
      if (section.includes(term)) score += 7;
      if (summary.includes(term)) score += 8;
      if (body.includes(term)) score += 2;
    }
    return score;
  };

  const render = (matches) => {
    results.replaceChildren();

    if (!matches.length) {
      status.textContent = 'No results for "' + query + '". Try different words.';
      return;
    }

    status.textContent = matches.length + (matches.length === 1 ? " result" : " results") +
      ' for "' + query + '".' + (matches.length > 40 ? " Showing the best 40." : "");

    for (const entry of matches.slice(0, 40)) {
      const card = document.createElement("article");
      card.className = "site-search__result";

      const heading = document.createElement("h2");
      heading.className = "site-search__result-title";
      const link = document.createElement("a");
      link.href = entry.url;
      link.textContent = entry.title;
      heading.append(link);
      card.append(heading);

      if (entry.section) {
        const section = document.createElement("p");
        section.className = "site-search__result-section";
        section.textContent = entry.section;
        card.append(section);
      }

      const snippet = excerpt(entry);
      if (snippet) {
        const description = document.createElement("p");
        description.className = "site-search__result-excerpt";
        description.textContent = snippet;
        card.append(description);
      }

      results.append(card);
    }
  };

  status.textContent = "Searching…";
  fetch(app.dataset.indexUrl)
    .then((response) => {
      if (!response.ok) throw new Error("Search index unavailable");
      return response.json();
    })
    .then((entries) => {
      if (!Array.isArray(entries)) throw new Error("Invalid search index");
      const matches = entries.map((entry) => ({ ...entry, score: scoreEntry(entry) }))
        .filter((entry) => entry.score > 0)
        .sort((a, b) => b.score - a.score || a.title.localeCompare(b.title));
      render(matches);
    })
    .catch(() => {
      status.textContent = "Search is temporarily unavailable. Please try again later.";
    });
})();
