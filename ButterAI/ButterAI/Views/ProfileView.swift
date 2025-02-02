//
//  ProfileView.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI



struct ProfileView: View {
    @Binding var isPresented: Bool
    @State private var showEditProfile = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Scrollable Content
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Image and Basic Info
                    VStack(spacing: 8) {
                        Image(MockData.sampleUser.profileImage ?? "placeholder_profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .padding(.top, 20)
                        
                        Text(MockData.sampleUser.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.customText)
                        
                        HStack(spacing: 4) {
                            Text("\(MockData.sampleUser.dayStreak) Days Streak!")
                                .foregroundColor(.customSecondary)
                        }
                        .font(.subheadline)
                        
                        Button {
                            showEditProfile = true
                        } label: {
                            Text("Edit Profile")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 120, height: 32)
                                .background(Color.customBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                    
                    Divider()
                        .background(Color.dividerColor)
                    
                    // Settings List
                    VStack(spacing: 0) {
                        settingsRow(icon: "clock.arrow.circlepath", title: "Past Achievements")
                        Divider().background(Color.dividerColor)
                        settingsRow(icon: "bell.fill", title: "Notifications")
                        Divider().background(Color.dividerColor)
                        settingsRow(icon: "lock.fill", title: "Privacy")
                        Divider().background(Color.dividerColor)
                        settingsRow(icon: "questionmark.circle.fill", title: "Help")
                        Divider().background(Color.dividerColor)
                        settingsRow(icon: "info.circle.fill", title: "About")
                        Divider().background(Color.dividerColor)
                        
                        // Sign Out Button
                        Button {
                            // Handle sign out
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.customRed)
                                    .font(.system(size: 16))
                                Text("Sign Out")
                                    .foregroundColor(.customRed)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(.systemGray4))
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color.settingsBackground)
                }
                .padding(.top, 60)
            }
            
            // Static Title and Back Button
            VStack {
                ZStack {
                    HStack {
                        Button {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.customBlue)
                                .padding(8)
                                .background(Color.customBlue.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                    
                    Text("Profile")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.customText)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .withCommonBackground()
        .sheet(isPresented: $showEditProfile) {
            // EditProfileView()
        }
    }
    
    private func settingsRow(icon: String, title: String) -> some View {
        Button {
            // Handle navigation
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.customSecondary)
                    .font(.system(size: 16))
                Text(title)
                    .foregroundColor(.customText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.systemGray4))
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    ProfileView(isPresented: .constant(true))
}
