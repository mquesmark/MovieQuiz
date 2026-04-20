# MovieQuiz

iOS quiz app about IMDb movie ratings. The app asks Yes/No questions, shows instant visual feedback, and tracks game statistics. Built with UIKit and MVP architecture.

## Features

- 10 questions per round from IMDb Top 250 and Most Popular movies
- Instant visual feedback with green and red borders
- Game statistics: current score, best score, and average accuracy
- Network error handling with retry option
- Portrait orientation only
- Supports iOS 15+

## Tech Stack

- Swift
- UIKit
- MVP
- URLSession
- Decodable
- UserDefaults
- XCTest (Unit and UI tests)

## Installation

1. Clone the repository:
   `git clone https://github.com/maximgv3/MovieQuiz.git`

2. Open the project:
   `open MovieQuiz.xcodeproj`

3. Run the app in Xcode.

## Architecture

The project uses the **MVP** pattern to separate UI, presentation logic, and services.

- **View** (`MovieQuizViewController`) — renders the interface
- **Presenter** (`MovieQuizPresenter`) — handles game flow and presentation logic
- **Services** — networking, statistics, and question generation

`ViewController ↔ Presenter ↔ Services`

## Testing

The project includes:

- Unit tests for `MoviesLoader` and helper logic
- Presenter tests
- UI tests for main user flows

Run all tests in Xcode with `Cmd + U`.

## Resources

- [Figma Design](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243)
- [IMDb API](https://imdb-api.com/api#Top250Movies-header)
