

import Foundation
import Combine

class GraphAlgoModel: ObservableObject {
    
    // MARK: - Stored Properties
    
    // General
    private var graphStack: Stack<Graph_Operations>
    @Published var graph: Graph_Operations
    @Published var step: Step
    
    // Node selection
    @Published var graphInitialNode: Node?
    @Published var graphFinalNode: Node?
    @Published var edgeSourceNode: Node?
    @Published var edgeDestNode: Node?
    
    // Algorithm selection
    @Published var selectedAlgorithm: Algorithm?
    @Published var selectedAlgorithmForExplanation: Algorithm = .bfs // Any
    
    private var cancellables = Set<AnyCancellable>()
    
    // Pop-ups
    
    @Published var showAlgorithmExplanationBox = false
    @Published var showTwoNodesAlert = false
    @Published var showDisconnectedGraphAlert = false
    @Published var showNoInitialFinalNodesAlert = false
    @Published var showNoInitialNodeAlert = false
    
    // MARK: - Computed Properties
    
    // Opacities
    var topBarOpacity: Double {
        if showAlgorithmExplanationBox {
            return 0
        }
        return 1
    }
    
    var clearRandomBarOpacity: Double {
        
        return 1
    }
    
    var algorithmsListOpacity: Double {
       
        return 1
    }
    
    // Navigation buttons
    var nextButtonOpacity: Double {
        switch step {
        case .nodeSelection:
           
            return 1
                
        case .edgeSelection,
                .edgesWeigthsSelection,
                .onlyInitialNodeSelection,
                .initialFinalNodesSelection,
                .askingForAlgorithmSelection:
            return 1
                
        default:
            return 0
        }
    }
    
    var previousButtonOpacity: Double {
        switch step {
        case .nodeSelection:
           
            return 1
                
        case .algorithmsList:
            return 0
                
        default:
            return 1
        }
    }
    
    var showPreviousButton: Bool {
        return !isShowingAlgorithmsList
                && !algorithmIsLive
    }

    var showNextButton: Bool {
        return !isShowingAlgorithmsList
                && !algorithmIsLive
    }
    
    // User interaction
    var isEditingNodesAndEdges: Bool {
            return step == .nodeSelection
            || step == .edgeSelection
            || step == .initialFinalNodesSelection
            || step == .onlyInitialNodeSelection
            || step == .edgesWeigthsSelection 
    }
    
    var isChoosingInitialFinalNodes: Bool {
        return step == .initialFinalNodesSelection
    }
    
    var isChoosingNodes: Bool {
        return step == .nodeSelection
    }
    
    var isSettingEdgesWeights: Bool {
        return step == .edgesWeigthsSelection
    }
    
    var isAboutToPickOrRunAlgorithm: Bool {
        return step == .askingForAlgorithmSelection
        
    }
    
    var isShowingAlgorithmsList: Bool {
        return step == .algorithmsList
    }
    
    var algorithmIsLive: Bool {
        return step == .liveAlgorithm
    }
    
    var showAlert: Bool {
        return showTwoNodesAlert
        || showDisconnectedGraphAlert
        || showNoInitialFinalNodesAlert
        || showNoInitialNodeAlert
    }
    
    // MARK: - Texts
    
    // Could use a stack in place of switch
    var topBarText: String {
        return getTopBarText(for: step, algorithm: selectedAlgorithm)
    }
    
    var alertText: String {
        if showTwoNodesAlert {
            return "The graph must have at least 2 nodes!"
            
        } else if showDisconnectedGraphAlert {
            return  """
         The graph is disconnected!\n
         There must not be either a node or\na subgraph disconnected from the whole.
         """
            
        } else if showNoInitialFinalNodesAlert {
            return "The graph must have both initial and final nodes set!"
            
        } else if showNoInitialNodeAlert {
            return "The graph must have an initial node set!"
            
        }
        return "Placeholder"
    }
    
    // MARK: - Init
    
    init() {
        graph = Graph_Operations.generate()
        graphStack = Stack()
        step = .nodeSelection
    }
    
    // MARK: - Methods
    
    func hideAlert() {
        showTwoNodesAlert = false
        showDisconnectedGraphAlert = false
        showNoInitialFinalNodesAlert = false
        showNoInitialNodeAlert = false
    }

}


// MARK: - Options bar

extension GraphAlgoModel {
    
    // MARK: Clear
    
    func clearButtonTapped() {
        switch step {
            case .nodeSelection:
                graph.retrieveAllNodes()
            case .edgeSelection:
                removeAllEdges()
            case .initialFinalNodesSelection, .onlyInitialNodeSelection:
                clearInitialFinalNodes()
            default: break
        }
    }
    
    private func clearInitialFinalNodes() {
        graphInitialNode?.place = .normal
        graphInitialNode = nil
        graphFinalNode?.place = .normal
        graphFinalNode = nil
    }
    
    // MARK: Random
    
    func randomButtonTapped() {
        switch step {
            case .nodeSelection:
                graph.randomizeNodeSelection()
            case .edgeSelection:
                randomizeEdgeSelection()
            case .onlyInitialNodeSelection:
                randomizeInitialNodeSelection()
            case .initialFinalNodesSelection:
                randomizeInitialFinalNodesSelection()
            default: break
        }
    }
    
    // MARK: Algorithms setup
    
    func selectAlgorithm(_ alg: Algorithm) {
        selectedAlgorithm = alg
        clearInitialFinalNodes()
        eraseAllEdgesWeights()
        graph.resetTree() 
        
        if selectedAlgorithm == .dijkstra || selectedAlgorithm == .prim {
            step = .edgesWeigthsSelection
            setRandomWeightsForAllEdges()
        } else {
            step = .initialFinalNodesSelection
        }
    }
    
    private func setRandomWeightsForAllEdges() {
        for nodeEdges in graph.edges {
            for edge in nodeEdges.filter({!$0.isReversed}) {
                setRandomWeightOn(edge)
            }
        }
    }
}

// MARK: - Nodes

extension GraphAlgoModel {
    
    func handleNodeTap(_ node: Node) {
        switch step {
            case .nodeSelection:
                node.toggleHiddenStatus()
            case .edgeSelection:
                attemptToConnect(node)
            case .onlyInitialNodeSelection:
                handleInitialStatus(for: node)
            case .initialFinalNodesSelection:
                handleInitialFinalStatus(for: node)
            default:
                break
        }
    }
    
    // MARK: Navigation issues
    
    private func hasLessThanTwoNodes() -> Bool {
        let nodesNumber = graph.unhiddenNodes.count
        if nodesNumber < 2 {
            showTwoNodesAlert = true
            return true
        }
        return false
    }
    
    private func hasNoInitialFinalNodes() -> Bool {
        let noNodes = (graphInitialNode == nil || graphFinalNode == nil)
        if noNodes { showNoInitialFinalNodesAlert = true }
        return noNodes
    }
    
    private func hasNoInitialNode() -> Bool {
        let noInitialNode = (graphInitialNode == nil)
        if noInitialNode { showNoInitialNodeAlert = true }
        return noInitialNode
    }
    
    // MARK: Initial and final nodes
    
    private func handleInitialFinalStatus(for node: Node) {
        if graphInitialNode == nil {
            graphInitialNode = node
            node.toggleInitialStatus()
        } else if node.isInitial { 
            graphInitialNode = nil
            node.toggleInitialStatus()
        } else if graphFinalNode == nil {
            graphFinalNode = node
            node.toggleFinalStatus()
        } else if node.isFinal {
            graphFinalNode = nil
            node.toggleFinalStatus()
        }
    }
    
    private func handleInitialStatus(for node: Node) {
        if graphInitialNode == nil {
            graphInitialNode = node
            node.toggleInitialStatus()
        } else if node.isInitial {
            graphInitialNode = nil
            node.toggleInitialStatus()
        } else {
            graphInitialNode?.toggleInitialStatus()
            graphInitialNode = node
            node.toggleInitialStatus()
        }
    }
    
    private func randomizeInitialFinalNodesSelection() {
        guard let randomInitial = graph.unhiddenNodes.randomElement() else { return }
        let possibleFinalNodes = graph.unhiddenNodes.filter({$0 != randomInitial})
        guard let randomFinal = possibleFinalNodes.randomElement() else { return }
        
        clearInitialFinalNodes()
        handleInitialFinalStatus(for: randomInitial)
        handleInitialFinalStatus(for: randomFinal)
    }
    
    private func randomizeInitialNodeSelection() {
        guard let randomInitial = graph.unhiddenNodes.randomElement() else { return }
        clearInitialFinalNodes()
        handleInitialStatus(for: randomInitial)
    }
    
}


// MARK: - Edges

extension GraphAlgoModel {
    
    // MARK: Tapping on an edge
    
    func handleEdgeTap(_ edge: Edge) {
        if edgeSourceNode != nil { return } // maybe middle of making an edge
        if step != .edgeSelection { return }
        removeEdge(edge)
    }
    
    private func removeEdge(_ edge: Edge) {
        let copy = graph.copy() // the copy is used because it perfectly triggers the swiftUI updagte
        copy.removeEdge(edge)    // in order to ui to update and make because can restore the states
        graph = copy     // State Safety: The original graph remains unchanged until the operation completes successfully l
    }
    
    // MARK: Weights
    
    func setRandomWeightOn(_ edge: Edge) {
        if !isSettingEdgesWeights { return }
        let randomWeight = Int.random(in: 1...50)
        graph.setWeightOn(edge: edge, weight: randomWeight)
    }
    
    private func eraseAllEdgesWeights() {
        for nodeEdges in graph.edges {
            nodeEdges.forEach {$0.eraseWeight()}
        }
    }
    
    // MARK: Tapping on a node
    
    private func attemptToConnect(_ node: Node) {
        if step != .edgeSelection { return }
        if node.isHidden { return }
        
        if edgeSourceNode == nil {
            // Picking source node
            edgeSourceNode = node
            edgeSourceNode?.type = .visited
        } else {
            do {
                // Picking dest node
                let sameNode = sourceNodeIsEqualTo(node)
                if sameNode { return }
                
                let alreadyConnected = try edgeConnectsSourceNode(to: node)
                if alreadyConnected { return }
                
                connectSourceNodeTo(node)
            } catch {
                // EdgeError: there is no source node
            }
        }
    }
    
    private func edgeConnectsSourceNode(to destNode: Node) throws -> Bool {
        guard let edgeSourceNode = edgeSourceNode else {
            throw EdgeError.nilSourceNode
        }
        
        return graph.edgeConnects(edgeSourceNode, to: destNode)
    }
    
    private func connectSourceNodeTo(_ node: Node) {
        // Create edge
        edgeDestNode = node
        let edge = Edge(from: edgeSourceNode!, to: edgeDestNode!)
        graph.addEdge(edge)
        
        // Clear selections
        edgeSourceNode?.type = .notVisited
        edgeSourceNode = nil
        edgeDestNode = nil
    }
    
    private func sourceNodeIsEqualTo(_ node: Node) -> Bool { // Checks if the user clicked the same node                                                            twice (i.e., the source node).
        if edgeSourceNode == node {
            edgeSourceNode?.type = .notVisited
            edgeSourceNode = nil
            return true
        }
        return false
    }
    
    // MARK: Clear and random
    
    private func removeAllEdges() {
        let copy = graph.copy()
        copy.removeAllEdges()
        graph = copy
        edgeSourceNode?.setAsNotVisited()
        edgeSourceNode = nil
    }
    
    private func randomizeEdgeSelection() {
        let copy = graph.copy()
        copy.edges = copy.getRandomEdges()
        graph = copy
        edgeSourceNode?.setAsNotVisited()
        edgeSourceNode = nil
    }
    
    // MARK: Navigation issues
    
    private func foundDisconnectedGraph() -> Bool {
        guard let randomNode = graph.unhiddenNodes.randomElement() else {
            return false
        }
        
        graph.dfs(startingFrom: randomNode)
        
        if !graph.visitedAllNodes {
            showDisconnectedGraphAlert = true
            graph.eraseVisitedNodesIdsArray()
            return true
        }
        graph.eraseVisitedNodesIdsArray()
        return false
    }
}

// MARK: - Navigation

extension GraphAlgoModel {
    
    private func retrievePreviousGraph() {
        if let poppedGraph = graphStack.pop() {
            graph = poppedGraph.copy()
        }
    }

    func nextButtonTapped() {
        switch step {
            case .nodeSelection:
                if hasLessThanTwoNodes() { return }
                graphStack.push(graph.copy())
                step = .edgeSelection
                
            case .edgeSelection:
                if foundDisconnectedGraph() { return }
                edgeSourceNode?.setAsNotVisited()
                edgeSourceNode = nil
                graphStack.push(graph.copy())
                step = .askingForAlgorithmSelection

            case .edgesWeigthsSelection:
                step = .onlyInitialNodeSelection
            
            case .onlyInitialNodeSelection:
                if hasNoInitialNode() { return }
                step = .askingForAlgorithmSelection
                
            case .initialFinalNodesSelection:
                if hasNoInitialFinalNodes() { return }
                step = .askingForAlgorithmSelection
                
            default: break
        }
    }
    
    func previousButtonTapped() {
        switch step {
            case .edgeSelection:
                retrievePreviousGraph()
                graph.unvisitAllNodes()
                edgeSourceNode = nil
                step = .nodeSelection
                
            case .askingForAlgorithmSelection:
                retrievePreviousGraph()
                selectedAlgorithm = nil
                clearInitialFinalNodes()
                eraseAllEdgesWeights()
                graph.unvisitAllNodes()
                graph.resetTree()
                step = .edgeSelection
                
            case .onlyInitialNodeSelection:
                clearInitialFinalNodes()
                step = .edgesWeigthsSelection
            
            case .initialFinalNodesSelection:
                selectedAlgorithm = nil
                clearInitialFinalNodes()
                step = .askingForAlgorithmSelection
                
            case .edgesWeigthsSelection:
                selectedAlgorithm = nil
                eraseAllEdgesWeights()
                step = .askingForAlgorithmSelection
                
            default: break
        }
    }
    
    func showAlgorithmsList() {
        eraseGraph()
        step = .algorithmsList
    }
    
    func runAlgorithm() {
        switch selectedAlgorithm {
        case .dfs:
            if hasNoInitialFinalNodes() { break }
            graph.unvisitAllNodes()
            
            step = .liveAlgorithm
            graph.runDFS(startingFrom: graphInitialNode!)
            observeAlgorithmFinishedStatus()
                
        case .bfs:
            if hasNoInitialFinalNodes() { break }
            graph.unvisitAllNodes()
            
            step = .liveAlgorithm
            graph.runBFS(startingFrom: graphInitialNode!)
            observeAlgorithmFinishedStatus()
            
        case .dijkstra:
            if hasNoInitialNode() { break }
            graph.unvisitAllNodes()
            graph.resetTree()
            step = .liveAlgorithm
            graph.runDjikstra(startingFrom: graphInitialNode!)
            observeAlgorithmFinishedStatus()
                
        default: // Prim
            if hasNoInitialNode() { break }
            graph.unvisitAllNodes()
            graph.resetTree()
            step = .liveAlgorithm
            graph.runPrim(startingFrom: graphInitialNode!)
            observeAlgorithmFinishedStatus()
        }
    }
    
    func eraseGraph() {
        graph.unvisitAllNodes()
        clearInitialFinalNodes()
    }
    
    private func observeAlgorithmFinishedStatus() {
        graph.$algorithmState.sink { state in
            if state == .notStarted {
                self.step = .askingForAlgorithmSelection
            }
        }.store(in: &cancellables)
    }
    
    func pauseResumeAlgorithm() {
        if graph.algorithmState == .running {
            graph.algorithmState = .paused
        } else { // .paused
            graph.algorithmState = .running
        }
    }
    
    func stopAlgorithm() {
        graph.stopTimer()
        graph.unvisitAllNodes()
        step = .askingForAlgorithmSelection
    }
}



func getTopBarText(for step: Step, algorithm: Algorithm?) -> String {
    switch step {
        case .nodeSelection:
            return "Select the nodes you want to remove from the graph"
            
        case .edgeSelection:
            return """
             Connect the nodes by tapping two of them in sequence
             Tap on an edge to remove it
             """
            
        case .askingForAlgorithmSelection:
            return algorithm?.rawValue ?? "Now, pick an algorithm to see it running live!"
            
        case .initialFinalNodesSelection:
            return "Select the nodes where the algorithm will start and finish"
            
        case .edgesWeigthsSelection:
            return "Tap on the numbers to select a random weight for the edges"
            
        case .onlyInitialNodeSelection:
            return "Select the node where the algorithm will start from"

            
        case .liveAlgorithm:
            return algorithm?.rawValue ?? "Unknown algorithm"
            
        default: // .algorithmsList
            return "Select algorithm"
    }
}
