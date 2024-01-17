//
//  EnterCodeView.swift
//  BeReal
//
//  Created by 강치우 on 1/2/24.
//

import SwiftUI
import Combine

struct EnterCodeView: View {
    
    @State var buttonActive = false
    
    @State var timeRemaining = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Text("PADO.")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .font(.system(size: 22))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                VStack {
                    VStack {
                        VStack(alignment: .center, spacing: 8) {
                            Text("+82 \(viewModel.phoneNumber)로 인증 번호를 보냈어요")
                                .foregroundStyle(.white)
                                .fontWeight(.heavy)
                                .font(.system(size: 16))
                            
                            VerificationView(otpText: $viewModel.otpText)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 25)
                        }
                        .padding(.top, 50)
                        
                        Spacer()
                    }
                    
                    VStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("휴대폰 번호를 잘못 입력하셨나요?")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                        }
                        
                        if timeRemaining > 0 {
                            Button {
                                if buttonActive {
                                    if viewModel.isExisted {
                                        Task {
                                            await viewModel.verifyOtp()
                                        }
                                    } else {
                                        Task {
                                            await viewModel.fetchUIDByPhoneNumber(phoneNumber: "+82\(viewModel.phoneNumber)")
                                            await viewModel.fetchUser()
                                        }
                                    }
                                }
                            } label: {
                                if timeRemaining > 0 {
                                    WhiteButtonView(buttonActive: $buttonActive, text: viewModel.otpText.count == 6 ? "계속하기" : "남은 시간 \(timeRemaining)초" )
                                }
                            }
                            .disabled(buttonActive ? false : true)
                            .onChange(of: viewModel.otpText) { oldValue, newValue in
                                if !newValue.isEmpty {
                                    buttonActive = true
                                } else if newValue.isEmpty {
                                    buttonActive = false
                                }
                            }
                        } else {
                            Button {
                                if buttonActive {
                                    Task {
                                        await self.viewModel.sendOtp()
                                        timeRemaining = 60
                                        buttonActive = false
                                    }
                                }
                            } label: {
                                WhiteButtonView(buttonActive: $buttonActive, text: "인증 번호 재전송" )
                            }
                        }
                    }
                }
            }
            .onReceive(timer, perform: { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    buttonActive = true
                }
            })
        }
        .navigationBarBackButtonHidden()
    }
    
    func limitText(_ upper: Int) {
        if viewModel.otpText.count > upper {
            viewModel.otpText = String(viewModel.otpText.prefix(upper))
        }
    }
}

//#Preview {
//    EnterCodeView()
//}
