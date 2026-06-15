package com.demo.mpmbackend.init;

import com.demo.mpmbackend.entity.AppUser;
import com.demo.mpmbackend.entity.Organisation;
import com.demo.mpmbackend.repository.AppUserRepository;
import com.demo.mpmbackend.repository.OrganisationRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
public class DataInitializer {

    private final AppUserRepository userRepository;
    private final OrganisationRepository orgRepository;
    private final PasswordEncoder passwordEncoder;

    @PostConstruct
    public void seed() {
        seedUsers();
        seedOrganisations();
    }

    private void seedUsers() {
        if (userRepository.count() > 0) return;

        userRepository.save(new AppUser(null, "admin", passwordEncoder.encode("admin123"), "ADMIN", "System Administrator"));
        userRepository.save(new AppUser(null, "debraj", passwordEncoder.encode("debraj123"), "USER", "Debraj"));
    }

    private void seedOrganisations() {
        if (orgRepository.count() > 0) return;

        Organisation google = new Organisation();
        google.setOrgId("101");
        google.setShortName("GOOGLE");
        google.setFullName("Google LLC");
        google.setCity("Mountain View");
        google.setState("CA");
        google.setCountry("USA");
        google.setType("Merchant");
        google.setSubType("Ecommerce");
        google.setAcquiringContractOwner("Chase Paymentech");
        google.setFeeRounding("bankers_agg");
        google.setDepositCreditLimit(new BigDecimal("500000.00"));
        orgRepository.save(google);

        Organisation amazon = new Organisation();
        amazon.setOrgId("102");
        amazon.setShortName("AMAZON");
        amazon.setFullName("Amazon.com Inc");
        amazon.setCity("Seattle");
        amazon.setState("WA");
        amazon.setCountry("USA");
        amazon.setType("Merchant");
        amazon.setSubType("Ecommerce");
        amazon.setAcquiringContractOwner("Wells Fargo");
        amazon.setFeeRounding("bankers_agg");
        amazon.setDepositCreditLimit(new BigDecimal("750000.00"));
        orgRepository.save(amazon);

        Organisation netflix = new Organisation();
        netflix.setOrgId("103");
        netflix.setShortName("NETFLIX");
        netflix.setFullName("Netflix Inc");
        netflix.setCity("Los Gatos");
        netflix.setState("CA");
        netflix.setCountry("USA");
        netflix.setType("Merchant");
        netflix.setSubType("Ecommerce");
        netflix.setAcquiringContractOwner("Bank of America");
        netflix.setFeeRounding("ROUND_UP");
        netflix.setDepositCreditLimit(new BigDecimal("300000.00"));
        orgRepository.save(netflix);

        Organisation hulu = new Organisation();
        hulu.setOrgId("104");
        hulu.setShortName("HULU");
        hulu.setFullName("Hulu LLC");
        hulu.setCity("Santa Monica");
        hulu.setState("CA");
        hulu.setCountry("USA");
        hulu.setType("Merchant");
        hulu.setSubType("Ecommerce");
        hulu.setAcquiringContractOwner("Citi");
        hulu.setParentOrgId("102");
        hulu.setFeeRounding("ROUND_DOWN");
        hulu.setDepositCreditLimit(new BigDecimal("150000.00"));
        orgRepository.save(hulu);

        Organisation disney = new Organisation();
        disney.setOrgId("105");
        disney.setShortName("DISNEY");
        disney.setFullName("The Walt Disney Company");
        disney.setCity("Burbank");
        disney.setState("CA");
        disney.setCountry("USA");
        disney.setType("Merchant");
        disney.setSubType("Retail");
        disney.setAcquiringContractOwner("US Bank");
        disney.setFeeRounding("bankers_agg");
        disney.setDepositCreditLimit(new BigDecimal("1000000.00"));
        orgRepository.save(disney);
    }
}
