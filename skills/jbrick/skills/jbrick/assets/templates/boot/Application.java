package {{FULL_PACKAGE}};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
{{ENABLE_SCHEDULING}}

@SpringBootApplication
{{SCHEDULING_ANNOTATION}}
public class {{SERVICE_CLASS}}Application {

    public static void main(String[] args) {
        SpringApplication.run({{SERVICE_CLASS}}Application.class, args);
    }
}
