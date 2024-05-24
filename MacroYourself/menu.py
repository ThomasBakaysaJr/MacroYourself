# Menu.py

"""Nutrition calculator built with Python and PyQt.
   Uses a mysql database to store nutritional data
"""

from logging import ERROR
import sys
from PyQt6.QtCore import Qt

from PyQt6.QtWidgets import (
    QApplication, 
    QMainWindow,
    QVBoxLayout, 
    QWidget,
    QGridLayout,
    QLineEdit,
    QPushButton,
    QBoxLayout
    )
import MacroYourself

WINDOW_SIZE = 235
DISPLAY_HEIGHT = 35
BUTTON_SIZE = 40

ERROR_MESSAGE = "ERROR"

class MenuWindow(QMainWindow):
    """Menu's main window (GUI or view)."""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("MacroYourself")
        self.setFixedSize(WINDOW_SIZE, WINDOW_SIZE)
        self.generalLayout = QVBoxLayout()
        
        centralWidget = QWidget(self)
        centralWidget.setLayout(self.generalLayout)
        self.setCentralWidget(centralWidget)
        self._createDisplay()
        self._createButtons()
        
    def _createDisplay(self):
        self.display = QLineEdit()
        self.display.setFixedHeight(DISPLAY_HEIGHT)
        self.display.setAlignment(Qt.AlignmentFlag.AlignRight)
        self.display.setReadOnly(True)
        self.generalLayout.addWidget(self.display)
        
    def _createButtons(self):
        self.buttonMap = {}
        buttonsLayout = QGridLayout()
        keyboard = [
            ["7","8","9","/","C"],
            ["4","5","6","*","("],
            ["1","2","3","-",")"],
            ["0","00",".","+","="]
            ]
        
        for row, keys in enumerate(keyboard):
            for col, key in enumerate(keys):
                self.buttonMap[key] = QPushButton(key)
                self.buttonMap[key].setFixedSize(BUTTON_SIZE, BUTTON_SIZE)
                buttonsLayout.addWidget(self.buttonMap[key], row, col)
                
        self.generalLayout.addLayout(buttonsLayout)
        
    def setDisplayText(self, text):
        """ Set text to display"""
        self.display.setText(text)
        self.display.setFocus()
        
    def displayText(self):
        """ Get the display text"""
        return self.display.text()
    
    def clearDisplay(self):
        """Clear the display"""
        self.setDisplayText("")
        
    def evaluateExpression(expression):
        """Attempt to evaluate the expression"""
        try:
            result = str(eval(expression, {}, {}))
        except Exception:
            result = ERROR_MESSAGE
        return result

def main():
    """Menu's main function."""
    macroApp = QApplication([])
    macroWindow = MenuWindow()
    macroWindow.show()
    sys.exit(macroApp.exec())

if __name__ == "__main__":
    main()