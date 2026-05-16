package com.turizim;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class TurIzimApplicationTest {

    @Test
    void contextLoads() {
        // Application context starts with test profile (in-memory H2).
    }
}
