//javac -encoding UTF8 JFx.java

import javafx.application.Application;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.Group;
import javafx.scene.text.Text;

public class JFx extends Application{
    public native void startJfx(Stage stage);
    public native void startJfy();
    
    public static void main(String[] args) {
    
        
        Application.launch(args);
    }

    @Override
    public void start(Stage stage) {
        System.out.println("start load dll");
        System.load("C:\\Users\\sadovoy\\Documents\\nimapps\\java2jnim\\tests\\jfx.dll");
        System.out.println("loaded dll");
        startJfy();
        
        
        // установка надписи
        Text text = new Text("Привет Hello from JavaFX!");
        text.setLayoutY(80);    // установка положения надписи по оси Y
        text.setLayoutX(100);   // установка положения надписи по оси X

        Group group = new Group(text);

        Scene scene = new Scene(group);
        stage.setScene(scene);
        //stage.setTitle("First Application");
        stage.setWidth(300);
        stage.setHeight(250);
        startJfx(stage);
        //stage.show();
    }
}