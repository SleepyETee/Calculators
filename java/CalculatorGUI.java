import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Map;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

/**
 * Comprehensive Scientific Calculator GUI using Swing.
 * Supports expression evaluation, trigonometric toggle, constants, memory, history, and themes.
 */
public class CalculatorGUI {
    private final Calculator calculator;
    private final JFrame frame;
    private final JTextField inputField;
    private final JTextArea outputArea;
    private final DefaultListModel<String> historyListModel;
    private final JList<String> historyList;
    private boolean darkTheme = false;

    public CalculatorGUI() {
        calculator = new Calculator();
        frame = new JFrame("Ultimate Scientific Calculator");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(1000, 600);

        inputField = new JTextField();
        outputArea = new JTextArea();
        outputArea.setEditable(false);
        outputArea.setFont(new Font("Monospaced", Font.PLAIN, 14));

        historyListModel = new DefaultListModel<>();
        historyList = new JList<>(historyListModel);

        JPanel mainPanel = new JPanel(new BorderLayout());
        mainPanel.add(inputField, BorderLayout.NORTH);
        mainPanel.add(new JScrollPane(outputArea), BorderLayout.CENTER);
        mainPanel.add(createButtonPanel(), BorderLayout.SOUTH);

        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, mainPanel, new JScrollPane(historyList));
        splitPane.setDividerLocation(700);
        frame.setContentPane(splitPane);
        frame.setVisible(true);
    }

    private JPanel createButtonPanel() {
        JPanel buttonPanel = new JPanel(new GridLayout(7, 6, 5, 5));
        String[] buttons = {
            "7", "8", "9", "/", "sqrt", "sin",
            "4", "5", "6", "*", "^", "cos",
            "1", "2", "3", "-", "log", "tan",
            "0", ".", "=", "+", "ln", "exp",
            "deg", "rad", "(", ")", "pi", "e",
            "Clear", "Deg/Rad", "MR", "Constants", "Help", "Ans",
            "Theme", "Plot"
        };

        for (String label : buttons) {
            JButton button = new JButton(label);
            button.addActionListener(e -> onButtonClick(label));
            buttonPanel.add(button);
        }

        return buttonPanel;
    }

    private void onButtonClick(String label) {
        switch (label) {
            case "=" -> evaluateExpression();
            case "Clear" -> inputField.setText("");
            case "Deg/Rad" -> calculator.toggleMode();
            case "MR" -> inputField.setText(inputField.getText() + calculator.recallMemory());
            case "Constants" -> showConstants();
            case "Help" -> showHelp();
            case "Ans" -> {
                int last = historyListModel.size() - 1;
                if (last >= 0) {
                    String lastResult = historyListModel.get(last);
                    String[] parts = lastResult.split(" = ");
                    if (parts.length == 2) inputField.setText(parts[1]);
                }
            }
            case "Theme" -> toggleTheme();
            case "Plot" -> plotFunction();
            default -> inputField.setText(inputField.getText() + label);
        }
    }

    private void toggleTheme() {
        darkTheme = !darkTheme;
        Color bg = darkTheme ? Color.DARK_GRAY : Color.WHITE;
        Color fg = darkTheme ? Color.WHITE : Color.BLACK;
        frame.getContentPane().setBackground(bg);
        inputField.setBackground(bg);
        inputField.setForeground(fg);
        outputArea.setBackground(bg);
        outputArea.setForeground(fg);
        historyList.setBackground(bg);
        historyList.setForeground(fg);
        frame.repaint();
    }

    private void plotFunction() {
        String expr = JOptionPane.showInputDialog(frame, "Enter function of x (e.g. sin(x)): ");
        if (expr == null || expr.isBlank()) return;

        XYSeries series = new XYSeries(expr);
        for (double x = -10; x <= 10; x += 0.1) {
            String fx = expr.replace("x", Double.toString(x));
            try {
                double y = calculator.evaluate(fx);
                series.add(x, y);
            } catch (Exception ignored) {}
        }

        XYSeriesCollection dataset = new XYSeriesCollection();
        dataset.addSeries(series);
        JFreeChart chart = ChartFactory.createXYLineChart(
            "Plot: " + expr, "x", "y",
            dataset, PlotOrientation.VERTICAL,
            true, true, false
        );

        JFrame plotFrame = new JFrame("Function Plot");
        plotFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        plotFrame.setSize(600, 400);
        plotFrame.add(new ChartPanel(chart));
        plotFrame.setVisible(true);
    }

    private void evaluateExpression() {
        String expr = inputField.getText();
        try {
            double result = calculator.evaluate(expr);
            String logEntry = expr + " = " + result;
            outputArea.append(logEntry + "\n");
            historyListModel.addElement(logEntry);
        } catch (Exception ex) {
            outputArea.append("Error: " + ex.getMessage() + "\n");
        }
    }

    private void showConstants() {
        StringBuilder sb = new StringBuilder("Constants:\n");
        for (Map.Entry<String, Double> entry : calculator.constants.entrySet()) {
            sb.append(entry.getKey()).append(" = ").append(entry.getValue()).append("\n");
        }
        JOptionPane.showMessageDialog(frame, sb.toString(), "Constants", JOptionPane.INFORMATION_MESSAGE);
    }

    private void showHelp() {
        String helpText = "Enter math expressions using common symbols:\n" +
                          "Operators: + - * / ^ ( )\n" +
                          "Functions: sqrt, log, ln, exp, sin, cos, tan, etc.\n" +
                          "Constants: pi, e, g, c, h\n" +
                          "Use '=' to evaluate.\n" +
                          "Use 'Deg/Rad' to toggle angle mode.\n" +
                          "Use 'Plot' to graph functions in terms of x.";
        JOptionPane.showMessageDialog(frame, helpText, "Help", JOptionPane.INFORMATION_MESSAGE);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(CalculatorGUI::new);
    }
}
