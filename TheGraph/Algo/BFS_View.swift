//
//  BFS_View.swift
//  TheGraph
//
//  Created by Kavya Khandelwal on 25/05/25.
//
import SwiftUI

struct BFS_View: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var showPopupAgain: Bool
    @StateObject private var graphModel = GraphAlgoModel()
    
    var body: some View {
        ZStack {
            Color("cream").edgesIgnoringSafeArea(.all)
            
            // Graph
            ZStack {
                // Edges and weights
                ForEach(0..<graphModel.graph.nodes.count, id: \.self) { i in
                    let nodeEdges = graphModel.graph.edges[i].filter({$0.inTree})
                    
                    ForEach(0..<nodeEdges.count, id: \.self) { j in
                        let edge = nodeEdges[j]
                        
                        EdgeView(edge: edge)
                            .onTapGesture {
                                withAnimation {
                                    graphModel.handleEdgeTap(edge)
                                }
                            }
                        
                        if edge.weight != 0 {
                            let x = edge.weightPosition.x
                            let y = edge.weightPosition.y
                            
                            WeightCard(edge: edge)
                                .position(x: x, y: y)
                                .zIndex(1)
                                .onTapGesture {
                                    withAnimation {
                                        graphModel.setRandomWeightOn(edge)
                                    }
                                }
                        }
                    } // ForEach
                }
                
                // Nodes
                ForEach(graphModel.graph.nodes) { node in
                    NodeView(node: node)
                        .position(node.position)
                        .onTapGesture {
                            withAnimation {
                                graphModel.handleNodeTap(node)
                            }
                        }
                }
            }
            
            
            // Alerts and popup
            if showPopupAgain && graphModel.showGenericInstructionPopup {
                AlertPopUpView(graphModel: graphModel, showPopupAgain: $showPopupAgain)
                    .transition(.move(edge: .bottom))
            }
            
            if graphModel.showAlert {
                AlertView(graphModel: graphModel)
                    .transition(.opacity)
            }
            

            // Replace the bottom section of your BFS_View with this:

            VStack {
                
                Text("B F S")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                
                // Top bar with instruction text
                TopBar(text: graphModel.topBarText)
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .padding(.top,10)
                    .opacity(graphModel.showAlert ? 0 : 1)
                
                Spacer()
                
                // Fixed bottom bar logic
                VStack {
                    // Show different bars based on the step
                    if graphModel.isEditingNodesAndEdges {
                        // Show BottomBar for editing steps
                        BottomBar(graphModel: graphModel)
                            .padding()
                    } else if graphModel.step == .askingForAlgorithmSelection {
                        // Show SelectAlgorithmAndRunBar for algorithm selection
                        SelectAlgorithmAndRunBar(graphModel: graphModel)
                            .padding()
                    } else if graphModel.isShowingAlgorithmsList {
                        // Show BFS algorithm picker when step == .algorithmsList
                        BFSPicker(graphModel: graphModel)
                            .padding()
                    } else if graphModel.step == .liveAlgorithm {
                        // Show StopPauseResumeBar during algorithm execution
                        StopPauseResumeBar(graphModel: graphModel)
                            .padding()
                    }
                    
                    // Navigation arrows
                    HStack {
                        Button(action: {
                            withAnimation {
                                if graphModel.isChoosingNodes {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    graphModel.previousButtonTapped()
                                }
                            }
                        }) {
                            Arrow(next: false)
                        }
                        .opacity(graphModel.previousButtonOpacity)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                if graphModel.isAboutToPickOrRunAlgorithm {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    graphModel.nextButtonTapped()
                                }
                            }
                        }) {
                            Arrow(next: true)
                        }
                        .opacity(graphModel.nextButtonOpacity)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
            }
            .padding()
        }
        .onAppear {
            print("BFS_View appeared")
            print("Initial step: \(graphModel.step)")
            print("Initial isEditingNodesAndEdges: \(graphModel.isEditingNodesAndEdges)")
            
            // Don't set algorithm yet - let's see the default state first
        }
        .navigationBarBackButtonHidden()
    }
}
