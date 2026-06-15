package com.demo.mpmbackend.controller;

import com.demo.mpmbackend.dto.LoginRequest;
import com.demo.mpmbackend.dto.LoginResponse;
import com.demo.mpmbackend.entity.AppUser;
import com.demo.mpmbackend.repository.AppUserRepository;
import com.demo.mpmbackend.security.JwtUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final AppUserRepository userRepository;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid username or password."));
        }

        AppUser user = userRepository.findByUsername(request.getUsername())
                .orElseThrow();

        String token = jwtUtil.generateToken(user.getUsername(), user.getRole());
        return ResponseEntity.ok(new LoginResponse(token, user.getUsername(), user.getRole(), user.getFullName()));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        // JWT is stateless; the client discards the token to "log out".
        return ResponseEntity.ok(Map.of("message", "Logged out successfully."));
    }
}
