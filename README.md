# TableFlow (Flutter APP)

**TableFlow** is a Flutter application designed to fetch and parse HTML tables or JSON API data from arbitrary URLs, presenting results in a dynamic, user-friendly DataTable interface. It supports both automatic table detection and manual selector entry, with fallback to JSON API mode or guidance toward backend integration for dynamic content scenarios.

## 🚀 Key Features

* **Automatic Table Detection**: Scans the provided URL for `<table>` elements, lists available tables, and previews headers or initial rows.
* **Manual Selector Mode**: If no `<table>` is found, users can input CSS selectors for row containers and column elements to extract tabular data from arbitrary HTML structures.
* **JSON API Mode**: For sites offering JSON endpoints, users can switch to JSON mode to automatically load and display data in a table format.
* **Dynamic DataTable Display**: Selected data is rendered with Flutter’s `DataTable`, supporting sortable columns and horizontal scrolling for wide tables.
* **Refresh Capability**: Users can refresh the current table, re-fetching data from the same URL or selector.
* **Error Handling and Loading States**: Clear loading indicators and descriptive error messages (with retry options) for network failures, parsing issues, or empty results.
* **Mobile-Friendly Workflow**: Designed for mobile UX: automatic detection presents “Table 1, Table 2…” choices instead of requiring developer tools. Guidance provided for dynamic or JavaScript-rendered pages.
* **Extensible Architecture**: Modular code organization (`services`, `screens`, `widgets`), facilitating future enhancements like pagination, caching, offline storage, or backend proxies.

## 📂 Project Structure

```
lib/
├── main.dart
├── services/
│   └── scraper_service.dart      # Logic for fetching & parsing HTML, automatic detection, manual selector parsing
├── screens/
│   ├── home_screen.dart          # Entry screen: URL input, automatic detection, manual mode fallback, JSON API switch
│   ├── table_list_screen.dart    # Lists detected tables with previews
│   ├── table_display_screen.dart # Displays selected table with DataTable and refresh capability
│   └── manual_selector_screen.dart # Accepts CSS selectors for custom parsing
├── widgets/
│   ├── dynamic_data_table.dart   # Builds DataTable from runtime column labels and rows
│   ├── loading_indicator.dart    # Centered CircularProgressIndicator
│   └── error_message.dart        # Error display with retry button
└── models/                       # (Optional) Data models for JSON API Mode
```

## 📦 Dependencies

* Flutter SDK (>=3.7.0)
* Dart SDK (>=2.18.0)
* **http**: for HTTP GET requests
* **html**: for static HTML parsing

In `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^0.13.5
  html: ^0.15.0
```

Install dependencies:

```bash
flutter pub get
```

## ⚙️ Installation & Usage

1. **Clone the repository**:

   ```bash
   git clone <repository_url>
   cd table_flow
   ```
2. **Install dependencies**:

   ```bash
   flutter pub get
   ```
3. **Run the app**:

   ```bash
   flutter run
   ```
4. **Enter a URL**: On the Home screen, provide a web page URL.

   * If the URL lacks a scheme, `https://` is prepended.
5. **Automatic Table Detection**:

   * Tap **Load Tables**. The app fetches HTML and scans for `<table>` elements.
   * A spinner is shown while loading.
   * If tables are found, you are navigated to a list of detected tables labeled “Table 1”, “Table 2”, etc., each showing a preview of headers or the first row.
   * Select a table to view full data in a sortable, horizontally scrollable DataTable. Use the refresh button to reload.
6. **Manual Selector Mode**:

   * If automatic detection finds no `<table>`, a **Manual Selector Mode** option appears.
   * In Manual Selector Mode, input CSS selectors for row containers and column elements, plus column labels, to extract data from arbitrary HTML structures.
   * Tap **Load with Selector** to fetch HTML and parse accordingly. Preview results in a DataTable.
7. **JSON API Mode**:

   * (Optional) For sites offering JSON endpoints, switch to JSON mode: enter a JSON API URL.
   * The app performs `http.get`, parses JSON (list or single object), infers columns from keys, and displays data in a DataTable.
8. **Dynamic Content Handling**:

   * For pages that load data via JavaScript (single-page applications, infinite scrolling, dynamic tables), static HTML parsing may fail.
   * The app will show “No tables found” or manual selector may not locate elements.
   * In such cases, consider using a backend proxy: e.g., a Flask or Node.js service with a headless browser (Puppeteer) that renders the page, extracts table or JSON data, and returns it to the mobile app.

## 📝 Detailed Behavior & Notes

### 1. Automatic Table Detection

* Fetches raw HTML with a realistic **User-Agent** header to reduce server rejections.
* Accepts any 2xx status code; follows redirects automatically.
* Parses HTML for `<table>` elements:

   * Extracts headers from `<th>` elements (in `<thead>` or first `<tr>`).
   * Extracts rows from `<td>` elements, skipping header rows.
   * If headers are absent but rows exist, auto-generates labels `Column 1`, `Column 2`, etc.
* If the list of detected tables is non-empty, navigates to TableListScreen.

### 2. TableListScreen

* Displays each detected table as a card:

   * Title: “Table N”.
   * Preview: If headers exist, shows “Headers: h1, h2, ...”; otherwise shows a truncated preview of the first row.
* On tap, navigates to TableDisplayScreen for full rendering.

### 3. TableDisplayScreen

* Renders the table via DynamicDataTable:

   * Sortable columns: tapping a header toggles ascending/descending sort.
   * Horizontal scrolling for wide tables.
* FloatingActionButton triggers refresh: re-fetch all tables from the same URL and update the same indexed table.
* If the table is empty, displays “Empty table.” message.

### 4. Manual Selector Mode

* Triggered when automatic detection yields no tables.
* Presents input fields:

   * **Row CSS Selector**: e.g., `div.item-row`, `.product-card`, etc.
   * **Column CSS Selectors (;)**: semicolon-separated selectors for each field, e.g., `span.name;span.price;div.quantity`.
   * **Column Labels (;)**: semicolon-separated labels matching the selectors count.
* On **Load with Selector**, fetches HTML and parses rows matching the row selector, then extracts cell text via column selectors.
* If parsing yields no rows, displays “No rows found with given selector.”
* Encourages users to adjust selectors or switch to JSON API mode if data is loaded dynamically.

### 5. JSON API Mode (Optional)

* Users can enter a JSON endpoint URL instead of an HTML page.
* Fetches JSON via `http.get`, decodes into `List` or single `Map`.
* Infers columns from map keys, displays data in DynamicDataTable.
* Handles loading states and errors similarly to HTML modes.

### 6. Error Handling & Guidance

* **Network Errors**: Timeouts, unreachable hosts, non-2xx responses result in descriptive error messages with a **Retry** button.
* **Parsing Errors**: If HTML parsing fails or selector yields no data, users are informed and can try alternative selectors or switch modes.
* **Dynamic Content Advice**: README and in-app messages guide users: “If the page loads content via JavaScript, consider using a backend rendering service or JSON API if available.”
* **Large Table Performance**: For very large tables, consider implementing pagination (`PaginatedDataTable`) or limiting displayed rows with “Load more” options.

### 7. Backend Proxy Integration

* For JS-rendered pages, the recommended architecture is:

   1. **Backend Service** (e.g., Flask, Node.js) uses a headless browser (Puppeteer, Playwright) to load the page.
   2. Extracts the target table or data, converts it to JSON.
   3. Exposes an API endpoint for the mobile app.
   4. Mobile app uses JSON API Mode to load and display data.
* This approach ensures reliable data extraction for dynamic sites.

## ⚠️ Limitations

* Static HTML parsing may not work for sites that load content via JavaScript. Such cases often require a server-side rendering approach (e.g., Flask + Puppeteer). While TableFlow aims to work on mobile, dynamic pages may be more reliably handled via a backend proxy or desktop-based solution.
* Modern web applications may not use `<table>` elements for tabular data; manual CSS selector entry or JSON API Mode may be necessary.
* CORS or HTTPS certificate issues may prevent direct HTML fetch; a proxy or backend service could mitigate these restrictions.
* Very large tables may cause performance issues on mobile; consider pagination, caching, or partial loading.
* This application has some shortcomings. It may be more suitable as a desktop application, but I am considering using it as a mobile application.

## 🛠 Development & Contribution

* **Clone & Setup**:

  ```bash
  git clone <repository_url>
  cd table_flow
  flutter pub get
  ```
* **Project Clean Architecture**: Keep `services`, `screens`, and `widgets` separate. Avoid mixing UI logic with parsing or network code.
* **Testing**: Add unit tests for parsing logic (`scraper_service`) and widget tests for UI flows.
* **Extensibility**: Implement features such as pagination, caching, or authentication for API key–protected sites.
* **Pull Requests**: Fork the repo, create feature branches, commit with clear messages, and open PRs for review.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE]

## 📞 Contact

For questions, issues, or collaboration:

* **Email**: [bektas.sari@gmail.com](mailto:bektas.sari)
* **GitHub**: [https://github.com/bektas-sari](https://github.com/bektas-sari)

---

> **TableFlow** empowers users on mobile or Flutter Web to effortlessly discover, extract, and display tabular data from static HTML or JSON endpoints, with clear guidance and fallbacks for dynamic content scenarios.
