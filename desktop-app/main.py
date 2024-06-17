# main.py
import sys
from PyQt5.QtCore import QUrl
from PyQt5.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QWidget
from PyQt5.QtWebEngineWidgets import QWebEngineView

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Next.js Desktop App")

        central_widget = QWidget(self)
        layout = QVBoxLayout(central_widget)
        web_view = QWebEngineView()

        # Load your Next.js app URL here (change this URL to your local development server or production server)
        web_view.setUrl(QUrl("https://localhost:3000/"))

        layout.addWidget(web_view)
        central_widget.setLayout(layout)
        self.setCentralWidget(central_widget)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    sys.exit(app.exec_())

