package {{FULL_PACKAGE}}.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackages = "{{FULL_PACKAGE}}.app.repository.jpa")
public class JpaConfig {}
