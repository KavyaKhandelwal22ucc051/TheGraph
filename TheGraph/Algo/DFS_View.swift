//
//  DFS_View.swift
//  TheGraph
//
//  Created by Kavya Khandelwal on 26/05/25.
//
import SwiftUI

struct DFS_View: View {
    
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
                   
                   // Nodes - Fixed this line
                   ForEach(Array(graphModel.graph.nodes), id: \.id) { node in
                       NodeView(node: node)
                           .position(node.position)
                           .onTapGesture {
                               withAnimation {
                                   graphModel.handleNodeTap(node)
                               }
                           }
                   }
               }
               
               // Alerts only (popup removed)
               
               if graphModel.showAlert {
                   AlertView(graphModel: graphModel)
                       .transition(.opacity) // Fade in animation
               }
               
//               if graphModel.showAlgorithmExplanationBox {
//                   ExplanationBoxView(graphModel: graphModel, algorithm: graphModel.selectedAlgorithmForExplanation)
//                       .transition(.move(edge: .top)) // Slide in from top animation
//               }
               
               VStack {
                   
                   Text("D F S")
                       .font(.system(size: 50))
                       .fontWeight(.bold)
                   
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
                           // Show DFS algorithm picker when step == .algorithmsList
                           DFSPicker(graphModel: graphModel)
                               .padding()
                       } else if graphModel.step == .liveAlgorithm {
                           // Show StopPauseResumeBar during algorithm execution
                           StopPauseResumeBar(graphModel: graphModel)
                               .padding()
                       }
                       
                       // Navigation arrows - Always show when appropriate
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
                   .opacity(graphModel.showAlert ? 0 : 1)
                   .padding(.bottom, 16)

               }
               .padding()
           }
           .onAppear {
               print("DFS_View appeared")
               print("Initial step: \(graphModel.step)")
               print("Initial isEditingNodesAndEdges: \(graphModel.isEditingNodesAndEdges)")
           }.navigationBarBackButtonHidden()
       }
}
