package com.turizim.domain;

import static org.assertj.core.api.Assertions.assertThat;

import com.turizim.admin.ViolationReportRepository;
import com.turizim.agency.AgencyRepository;
import com.turizim.application.TourApplicationRepository;
import com.turizim.assignment.AssignmentRepository;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.deposit.MockDepositRepository;
import com.turizim.publication.PublicationProofRepository;
import com.turizim.tour.TourRepository;
import com.turizim.user.UserAccountRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class JpaRepositoriesRegisteredTest {

    @Autowired
    private ApplicationContext applicationContext;

    @Test
    void allJpaRepositoriesAreRegistered() {
        assertThat(applicationContext.getBean(UserAccountRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(AgencyRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(CreatorProfileRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(TourRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(TourApplicationRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(AssignmentRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(MockDepositRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(PublicationProofRepository.class)).isNotNull();
        assertThat(applicationContext.getBean(ViolationReportRepository.class)).isNotNull();
    }
}
